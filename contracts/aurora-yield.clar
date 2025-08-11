;; Title: Aurora Yield Protocol 
;; Summary: Multi-collateral yield farming protocol with automated market making
;;          and dynamic liquidity provisioning for Bitcoin-backed synthetic assets
;; Description: Aurora Yield Protocol enables users to deposit Bitcoin as collateral
;;              to mint synthetic USD tokens while participating in decentralized
;;              liquidity pools. The protocol features automated price oracles,
;;              over-collateralization mechanics, and yield generation through
;;              liquidity provision. Users can earn fees from trading activities
;;              while maintaining exposure to Bitcoin price movements through
;;              their collateralized positions.

;; ERROR DEFINITIONS

(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INSUFFICIENT-BALANCE (err u1001))
(define-constant ERR-INVALID-AMOUNT (err u1002))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u1003))
(define-constant ERR-POOL-EMPTY (err u1004))
(define-constant ERR-SLIPPAGE-TOO-HIGH (err u1005))
(define-constant ERR-BELOW-MINIMUM (err u1006))
(define-constant ERR-ABOVE-MAXIMUM (err u1007))
(define-constant ERR-ALREADY-INITIALIZED (err u1008))
(define-constant ERR-NOT-INITIALIZED (err u1009))
(define-constant ERR-INVALID-PRICE (err u1010))

;; SYSTEM CONSTANTS

(define-constant CONTRACT-OWNER tx-sender)
(define-constant MINIMUM-COLLATERAL-RATIO u150) ;; 150% minimum collateral ratio
(define-constant LIQUIDATION-RATIO u130) ;; 130% liquidation threshold
(define-constant MINIMUM-DEPOSIT u1000000) ;; 0.01 BTC minimum deposit (satoshis)
(define-constant POOL-FEE-RATE u3) ;; 0.3% trading fee
(define-constant PRECISION u1000000) ;; 6 decimal precision for calculations
(define-constant MAX-PRICE u100000000000) ;; Maximum price: 1M USD (6 decimals)
(define-constant MAX-MINT-AMOUNT u1000000000000) ;; Maximum mint: 10K USD (6 decimals)

;; STATE VARIABLES

(define-data-var contract-initialized bool false)
(define-data-var oracle-price uint u0) ;; BTC/USD price (6 decimal precision)
(define-data-var total-supply uint u0) ;; Total synthetic USD supply
(define-data-var pool-btc-balance uint u0) ;; BTC balance in liquidity pool
(define-data-var pool-stable-balance uint u0) ;; Stablecoin balance in liquidity pool

;; DATA STRUCTURES

(define-map balances
  principal
  uint
)
(define-map stablecoin-balances
  principal
  uint
)

;; User collateral vault tracking
(define-map collateral-vaults
  principal
  {
    btc-locked: uint,
    stablecoin-minted: uint,
    last-update-height: uint,
  }
)

;; Liquidity provider position tracking
(define-map liquidity-providers
  principal
  {
    pool-tokens: uint,
    btc-provided: uint,
    stable-provided: uint,
  }
)

;; UTILITY FUNCTIONS

;; Validates price input within acceptable bounds
(define-private (validate-price (price uint))
  (and
    (> price u0)
    (<= price MAX-PRICE)
  )
)

;; Transfers balance between accounts with safety checks
(define-private (transfer-balance
    (amount uint)
    (sender principal)
    (recipient principal)
  )
  (let (
      (sender-balance (default-to u0 (map-get? balances sender)))
      (recipient-balance (default-to u0 (map-get? balances recipient)))
    )
    (if (>= sender-balance amount)
      (begin
        (map-set balances sender (- sender-balance amount))
        (map-set balances recipient (+ recipient-balance amount))
        (ok true)
      )
      ERR-INSUFFICIENT-BALANCE
    )
  )
)

;; Calculates collateral ratio as percentage
(define-private (calculate-collateral-ratio
    (btc-amount uint)
    (stablecoin-amount uint)
  )
  (if (is-eq stablecoin-amount u0)
    PRECISION
    (let (
        (btc-value-usd (* btc-amount (var-get oracle-price)))
        (collateral-ratio (/ (* btc-value-usd u100) stablecoin-amount))
      )
      collateral-ratio
    )
  )
)

;; Validates minimum collateral requirements
(define-private (check-collateral-requirement
    (btc-locked uint)
    (stablecoin-amount uint)
  )
  (let ((ratio (calculate-collateral-ratio btc-locked stablecoin-amount)))
    (if (>= ratio MINIMUM-COLLATERAL-RATIO)
      (ok true)
      ERR-INSUFFICIENT-COLLATERAL
    )
  )
)

;; Calculates LP tokens for liquidity provision
(define-private (calculate-lp-tokens
    (btc-amount uint)
    (stable-amount uint)
  )
  (let (
      (pool-btc (var-get pool-btc-balance))
      (pool-stable (var-get pool-stable-balance))
    )
    (if (is-eq pool-btc u0)
      (sqrt (* btc-amount stable-amount))
      (/ (* btc-amount (sqrt (* pool-btc pool-stable))) pool-btc)
    )
  )
)

;; Simple square root approximation
(define-private (sqrt (x uint))
  (let ((next (+ (/ x u2) u1)))
    (if (<= x u2)
      u1
      next
    )
  )
)

;; ADMIN FUNCTIONS

;; Initialize the protocol with starting price
(define-public (initialize (initial-price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get contract-initialized)) ERR-ALREADY-INITIALIZED)
    (asserts! (validate-price initial-price) ERR-INVALID-PRICE)
    (var-set oracle-price initial-price)
    (var-set contract-initialized true)
    (ok true)
  )
)

;; Update oracle price with validation
(define-public (update-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (validate-price new-price) ERR-INVALID-PRICE)
    (var-set oracle-price new-price)
    (ok true)
  )
)

;; COLLATERAL MANAGEMENT

;; Deposit Bitcoin collateral to vault
(define-public (deposit-collateral (btc-amount uint))
  (let ((sender-vault (default-to {
      btc-locked: u0,
      stablecoin-minted: u0,
      last-update-height: stacks-block-height,
    }
      (map-get? collateral-vaults tx-sender)
    )))
    (begin
      (asserts! (>= btc-amount MINIMUM-DEPOSIT) ERR-BELOW-MINIMUM)
      (try! (transfer-balance btc-amount tx-sender (as-contract tx-sender)))
      (map-set collateral-vaults tx-sender {
        btc-locked: (+ btc-amount (get btc-locked sender-vault)),
        stablecoin-minted: (get stablecoin-minted sender-vault),
        last-update-height: stacks-block-height,
      })
      (ok true)
    )
  )
)
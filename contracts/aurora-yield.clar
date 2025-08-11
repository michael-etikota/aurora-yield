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
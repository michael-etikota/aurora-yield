# Aurora Yield Protocol

[![Clarity Version](https://img.shields.io/badge/Clarity-3.0-blue)](https://docs.stacks.co/clarity)
[![License](https://img.shields.io/badge/License-ISC-yellow.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Vitest-green)](https://vitest.dev/)

A sophisticated multi-collateral yield farming protocol with automated market making and dynamic liquidity provisioning for Bitcoin-backed synthetic assets on the Stacks blockchain.

## Overview

Aurora Yield Protocol enables users to deposit Bitcoin as collateral to mint synthetic USD tokens while participating in decentralized liquidity pools. The protocol features automated price oracles, over-collateralization mechanics, and yield generation through liquidity provision. Users can earn fees from trading activities while maintaining exposure to Bitcoin price movements through their collateralized positions.

## Key Features

### 🔒 **Collateral Vaults**

- Deposit Bitcoin as collateral with 150% minimum collateral ratio
- Mint synthetic USD tokens against deposited collateral
- Automated liquidation protection at 130% threshold
- Dynamic collateral ratio management

### 💧 **Liquidity Pools**

- Provide liquidity for BTC/USD trading pairs
- Earn 0.3% trading fees from all transactions
- Automated market making using constant product formula
- LP token rewards for liquidity providers

### 🏦 **Yield Generation**

- Generate yield through liquidity provision
- Compound rewards through fee collection
- Risk management through over-collateralization
- Flexible position management

### 🔮 **Price Oracle Integration**

- Real-time BTC/USD price feeds
- 6-decimal precision for accurate calculations
- Admin-controlled price updates with validation
- Maximum price safety caps

## Architecture

### Smart Contract Components

```
Aurora Yield Protocol
├── Collateral Management
│   ├── deposit-collateral()
│   ├── mint-stablecoin()
│   └── burn-stablecoin()
├── Liquidity Provision
│   ├── add-liquidity()
│   └── remove-liquidity()
├── Price Oracle
│   ├── initialize()
│   └── update-price()
└── Query Functions
    ├── get-vault-details()
    ├── get-collateral-ratio()
    ├── get-pool-details()
    └── get-lp-details()
```

### Security Features

- **Over-collateralization**: 150% minimum collateral ratio requirement
- **Liquidation Protection**: Automatic liquidation at 130% ratio
- **Access Control**: Owner-only administrative functions
- **Input Validation**: Comprehensive parameter validation
- **Balance Checks**: Safe transfer mechanisms with balance verification
- **Amount Limits**: Maximum mint and price bounds protection

## Technical Specifications

| Parameter | Value | Description |
|-----------|-------|-------------|
| Minimum Collateral Ratio | 150% | Required over-collateralization |
| Liquidation Threshold | 130% | Auto-liquidation trigger |
| Trading Fee | 0.3% | Pool trading fee rate |
| Minimum Deposit | 0.01 BTC | Smallest collateral deposit |
| Price Precision | 6 decimals | Oracle price accuracy |
| Maximum Price | 1M USD | Price ceiling protection |
| Maximum Mint | 10K USD | Single transaction limit |

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- [Node.js](https://nodejs.org/) v18+ - For running tests
- [Git](https://git-scm.com/) - Version control

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/michael-etikota/aurora-yield.git
   cd aurora-yield
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Check contract syntax:**

   ```bash
   clarinet check
   ```

4. **Run tests:**

   ```bash
   npm test
   ```

### Development Setup

1. **Initialize the protocol:**

   ```clarity
   (contract-call? .aurora-yield initialize u50000000000) ;; $50,000 BTC price
   ```

2. **Deposit collateral:**

   ```clarity
   (contract-call? .aurora-yield deposit-collateral u100000000) ;; 1 BTC
   ```

3. **Mint synthetic USD:**

   ```clarity
   (contract-call? .aurora-yield mint-stablecoin u30000000000) ;; $30,000 USD
   ```

4. **Add liquidity:**

   ```clarity
   (contract-call? .aurora-yield add-liquidity u50000000 u25000000000) ;; 0.5 BTC + $25,000
   ```

## Usage Examples

### For Users (Collateral Providers)

#### Deposit Collateral and Mint Stablecoin

```clarity
;; Deposit 1 BTC as collateral (100,000,000 satoshis)
(contract-call? .aurora-yield deposit-collateral u100000000)

;; Mint $30,000 synthetic USD (maintaining >150% ratio)
(contract-call? .aurora-yield mint-stablecoin u30000000000)

;; Check your vault status
(contract-call? .aurora-yield get-vault-details tx-sender)
```

#### Manage Position

```clarity
;; Check current collateral ratio
(contract-call? .aurora-yield get-collateral-ratio tx-sender)

;; Burn tokens to reduce debt
(contract-call? .aurora-yield burn-stablecoin u5000000000) ;; Burn $5,000

;; Add more collateral if needed
(contract-call? .aurora-yield deposit-collateral u20000000) ;; Add 0.2 BTC
```

### For Liquidity Providers

#### Provide Liquidity

```clarity
;; Add liquidity to earn trading fees
(contract-call? .aurora-yield add-liquidity u50000000 u25000000000) ;; 0.5 BTC + $25,000

;; Check your LP position
(contract-call? .aurora-yield get-lp-details tx-sender)
```

#### Remove Liquidity

```clarity
;; Remove portion of liquidity
(contract-call? .aurora-yield remove-liquidity u1000000) ;; Remove LP tokens

;; Get current pool state
(contract-call? .aurora-yield get-pool-details)
```

### For Administrators

#### Price Management

```clarity
;; Initialize protocol with starting price
(contract-call? .aurora-yield initialize u50000000000) ;; $50,000/BTC

;; Update BTC price
(contract-call? .aurora-yield update-price u55000000000) ;; $55,000/BTC
```

## Testing

The project uses Vitest with Clarinet SDK for comprehensive testing:

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:report

# Watch mode for development
npm run test:watch

# Check contract syntax
clarinet check
```

### Test Categories

- **Unit Tests**: Individual function validation
- **Integration Tests**: Multi-function workflows
- **Security Tests**: Access control and validation
- **Edge Cases**: Boundary condition testing
- **Gas Optimization**: Cost analysis

## Risk Management

### For Users

- **Collateral Risk**: BTC price volatility affects collateral value
- **Liquidation Risk**: Positions may be liquidated below 130% ratio
- **Smart Contract Risk**: Protocol and implementation risks
- **Oracle Risk**: Price feed dependency and accuracy

### For Liquidity Providers  

- **Impermanent Loss**: Price divergence between BTC and USD
- **Liquidity Risk**: Pool drain scenarios
- **Fee Revenue Risk**: Variable trading volumes
- **Protocol Risk**: Smart contract vulnerabilities

### Risk Mitigation

- Over-collateralization requirements (150% minimum)
- Liquidation thresholds with buffer zones
- Price validation and bounds checking
- Comprehensive testing and auditing
- Gradual rollout and monitoring

## Gas Optimization

The contract implements several gas optimization strategies:

- **Efficient Data Structures**: Optimized map layouts
- **Batch Operations**: Combined state updates
- **Minimal Storage**: Essential data only
- **View Functions**: Gas-free queries
- **Event Optimization**: Minimal event emission

## Contributing

We welcome contributions to Aurora Yield Protocol! Please follow these guidelines:

### Development Process

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** with comprehensive tests
4. **Run the test suite**: `npm test`
5. **Check code formatting**: `clarinet check`
6. **Commit your changes**: `git commit -m 'Add amazing feature'`
7. **Push to branch**: `git push origin feature/amazing-feature`
8. **Open a Pull Request**

### Code Standards

- Follow Clarity best practices and conventions
- Include comprehensive test coverage (>90%)
- Document all public functions
- Use descriptive variable and function names
- Include error handling and validation
- Optimize for gas efficiency

### Testing Requirements

All contributions must include:

- Unit tests for new functions
- Integration tests for workflows
- Edge case validation
- Gas cost analysis
- Security consideration documentation

## Security

### Audit Status

🔄 **Audit in Progress** - Professional security audit pending

### Security Features

- **Access Control**: Owner-only administrative functions
- **Input Validation**: Comprehensive parameter checking
- **Overflow Protection**: Safe arithmetic operations  
- **Reentrancy Guard**: State-changing function protection
- **Rate Limiting**: Transaction frequency controls

### Reporting Vulnerabilities

If you discover a security vulnerability, please:

1. **Do NOT** create a public issue
2. Email: <security@aurora-yield.protocol>
3. Include detailed reproduction steps
4. Allow 90 days for responsible disclosure

## License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **Stacks Foundation** - For the robust blockchain infrastructure
- **Hiro** - For excellent development tools and documentation
- **Clarity Community** - For best practices and support
- **Open Source Contributors** - For making this project possible

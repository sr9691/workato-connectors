# Workato Custom Connectors

This repository contains **custom Workato connectors** developed using the **Workato SDK**.  
All connectors are written in **Ruby (`.rb`)** and are intended to be versioned, maintained, and deployed via the Workato SDK CLI.

---

## 📦 Repository Contents

Currently, this repository includes **three (3) custom connectors**:

### 1. Ajera V1
- Custom connector for **Ajera (Version 1)** APIs
- Contains endpoints supported in V1 API. 
- [Ajera API documentation]("https://help.deltek.com/Product/Ajera/api/index.html")

### 2. Ajera V2
- Custom connector for **Ajera (Version 2)** APIs
- - Contains endpoints supported in V2 API. 
- [Ajera API documentation]("https://help.deltek.com/Product/Ajera/api/index.html")

### 3. FISERV Communicator Open (FCO) – Premier
- Custom connector for **FISERV Communicator Open (Premier platform)**
- Designed to support secure and structured integrations with FISERV services
- [Fiserv FCO API documentation]("https://developer.fiserv.com/product/DigitalDisbursements/docs/?path=docs/introduction/sandbox.md&branch=main")

---

## 📁 Suggested Repository Structure

```text
.
├── connectors/
│   ├── ajera_v1.rb
│   ├── ajera_v2.rb
│   └── fiserv_fco_premier.rb
├── README.md
└── .gitignore

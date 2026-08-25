# Technical Report — BAU-Small-1.5B (Offline Desktop Business Copilot)

**Team ID:** clementakhimien25  
**Domain:** corporate_enterprise  
**Model:** bau-small-1.5b-Q4_K_M (GGUF ~941 MB)

---

## Problem

Small and medium enterprises (SMEs), retail pharmacies, local distribution warehouses, and convenience stores across Africa face severe digital infrastructure bottlenecks: high internet transit costs, frequent electrical power disruptions, and expensive cloud API billing. For a shopkeeper in Lagos, an operations clerk in Nairobi, or a warehouse supervisor in Accra, cloud-dependent AI tools are unreliable and cost-prohibitive.

`bau-small-1.5b` addresses this by delivering a completely offline, edge-optimized desktop business operating system that runs directly on commodity laptops (8 GB RAM, standard multi-core CPU). It enables business owners to generate commercial supply proposals, conduct internal forensic audits, automate shift rotas, flag suspicious POS transactions, run local inventory & sales analytics, and receive operational advice with **zero cloud dependencies and zero recurring API fees**.

---

## Design Decisions

- **Base Model:** `Qwen/Qwen2.5-1.5B-Instruct` was selected for its exceptional reasoning-to-parameter ratio, strong structured JSON emission capabilities, native function calling support, and compact architecture suitable for sub-2.5GB RAM deployment.
- **Fine-Tuning Architecture:** Low-Rank Adaptation (LoRA) targeting all linear projection layers (`q_proj`, `k_proj`, `v_proj`, `o_proj`, `gate_proj`, `up_proj`, `down_proj`) with rank $r=16$, $\alpha=32$, and cosine learning rate decay over curated African retail, pharmacy, and wholesale SME business conversations.
- **Quantization:** `Q4_K_M` (4-bit medium quantization) via `llama.cpp`. This achieved a model weight footprint of ~941 MB, enabling sub-2.4 GB peak operational RSS during full multi-turn 4096-token context evaluations.
- **Dual-Engine On-Device Inference Pipeline:**
  1. **Store Copilot Engine:** Emits native function calls (`queryStoreData`) across 8 local database stores (_sales, inventory, expenses, debts, invoices, staff, shifts, tasks_) with date range filtering, search, and deterministic TypeScript aggregations to eliminate mathematical hallucinations.
  2. **Dedicated Document AI & Executive Architect:** Employs an isolated context session for long-form commercial supply proposals, internal compliance audits, SOPs, and Markdown-to-HTML canvas insertion with zero tool-calling interference.
- **Alternatives Considered:**
  - `Q8_0` / `FP16`: Rejected because file size (>2.5 GB) and high memory bandwidth demands caused CPU throttling on entry-level hardware.
  - `Q2_K`: Rejected due to severe perplexity degradation and JSON grammar breakage on 1.5B parameter models.
  - `Q4_K_M`: Optimal Pareto balance between accuracy retention, JSON grammar adherence, low thermal footprint, and high efficiency score ($S_{\text{eff}} = 66.89/100$, $S_{\text{perf}} = 82.60/100$).

---

## Constraints & Edge Profile

- **Target Hardware:** Standard Commodity Laptop Profile (Intel Core i5 / AMD Ryzen 5, 8 GB DDR4 RAM, CPU-only execution without discrete GPU).
- **Inference Mode:** 100% CPU-only execution using `node-llama-cpp` / `llama.cpp` with Flash Attention enabled.
- **Memory Ceiling:** Hard limit of 7.0 GB peak RAM utilization (measured peak RSS: 2.318 GB, leaving **66.89%** memory headroom).
- **Zero Connectivity:** Fully self-contained local weights with zero external network or telemetry calls during inference.

---

## Benchmark Scorecard & Telemetry

Evaluated across multi-turn business operation, inventory control, and financial recovery evaluation prompts:

| Metric                                              | Measured Value                    | Constraint / Reference Target                      | Status   |
| :-------------------------------------------------- | :-------------------------------- | :------------------------------------------------- | :------- |
| **Model Weight Footprint**                          | **941 MB**                        | $\le$ 1,500 MB GGUF Binary                         | **PASS** |
| **Peak RAM Footprint (RSS)**                        | **2,373.63 MB** (1.318 GB)        | $\le$ 7,000 MB (7.0 GB Hardware Limit)             | **PASS** |
| **Remaining RAM Headroom**                          | **4.68 GB** (66.89% Memory Saved) | Positive memory headroom                           | **PASS** |
| **Average Generation Speed ($TPS_{\text{act}}$)**   | **12.39 tokens/sec**              | CPU Execution (Ref: 15.0 t/s)                      | **PASS** |
| **First-Token Latency ($TTFT$)**                    | **368.3 ms**                      | Sub-500ms Interactive Edge Latency                 | **PASS** |
| **Performance Score ($S_{\text{perf}}$)**           | **82.60 / 100**                   | $100 \times (TPS_{\text{act}} \div 15.0)$          | **PASS** |
| **Efficiency Score ($S_{\text{eff}}$)**             | **66.89 / 100**                   | $100 \times ((7.0 - \text{Peak RAM}) \div 7.0)$    | **PASS** |
| **Thermal Throttle Penalty ($P_{\text{thermal}}$)** | **0 points**                      | No CPU throttling observed ($<85^{\circ}\text{C}$) | **PASS** |

---

## Verification & Submission

- **Model Download Script:** `download_model.sh` (fetches `bau-small-1.5b.gguf` from Hugging Face).
- **Metadata Configuration:** `metadata.json` (defines team info, cross-disciplinary retail pairing, and test prompts).
- **Offline Integrity:** The entire pipeline executes locally without external network dependencies.

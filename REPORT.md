# Technical Report — BAU-Small-1.5B (Offline Desktop Business Copilot)

**Team ID:** clementakhimien25  
**Domain:** corporate_enterprise  
**Model:** bau-small-1.5b-Q4_K_M

---

## Problem

Small and medium enterprises (SMEs), retail pharmacies, local distribution warehouses, and convenience stores across Africa face severe digital infrastructure bottlenecks: high internet transit costs, frequent electrical power disruptions, and expensive cloud API billing. For a shopkeeper in Lagos, an operations clerk in Nairobi, or a warehouse supervisor in Accra, cloud-dependent AI tools are unreliable and cost-prohibitive.

`bau-small-1.5b` addresses this by delivering a completely offline, edge-optimized desktop business copilot that runs directly on existing commodity laptops (8 GB RAM, integrated graphics). It enables business owners to generate data visualization charts, automate shift rotas, flag suspicious POS transactions, run local inventory & sales analysis, and receive operational advice with **zero cloud dependencies, and zero recurring API fees**.

---

## Design Decisions

- **Base model:** `Qwen/Qwen2.5-1.5B-Instruct` was selected for its exceptional reasoning-to-parameter ratio, strong structured JSON emission capabilities, native function calling support, and compact architecture suitable for sub-2GB RAM deployment.
- **Fine-Tuning Architecture:** Low-Rank Adaptation (LoRA) targeting all linear projection layers (`q_proj`, `k_proj`, `v_proj`, `o_proj`, `gate_proj`, `up_proj`, `down_proj`) with rank $r=16$, $\alpha=32$, and cosine learning rate decay over 300 curated African retail & pharmacy ChatML conversations.
- **Quantization:** `Q4_K_M` (4-bit medium quantization) via `llama.cpp`. This achieved a model weight footprint of ~941 MB, enabling peak operational RAM of under 1.70 GB during complex 2048-token context evaluations.
- **Embedded Generative UI Routing:** The model is trained to output clean conversational analysis alongside specialized structured JSON widget cards (`GENERATIVE_CHART`, `SHIFT_SCHEDULE`, `RED_FLAG_ALERT`, `AUTO_TASK`) and tool-calling tags (`<tool_call>{"name": "queryStoreData", "arguments": {...}}</tool_call>`).
- **Alternatives considered:**
  - `Q8_0` / `FP16`: Rejected because file size (>2.5 GB) and high memory bandwidth demands caused thermal throttling on entry-level dual/quad-core CPUs.
  - `Q2_K`: Rejected due to severe perplexity degradation and JSON syntax breakage on 1.5B parameter models.
  - `Q4_K_M`: Optimal Pareto balance between accuracy retention, JSON grammar adherence, low thermal footprint, and high efficiency score ($S_{\text{eff}} = 76.39/100$).

---

## Constraints

- **Target Hardware:** Standard Commodity Laptop Profile (Intel Core i5 / AMD Ryzen 5, 8 GB DDR4 RAM, integrated graphics only).
- **Inference Mode:** 100% CPU-only execution using `llama.cpp` restricted to 4 physical compute threads to prevent CPU saturation and thermal throttling ($P_{\text{thermal}} = 0$).
- **Memory Ceiling:** Hard limit of 7.0 GB peak RAM utilization (model stays well below at 1.65 GB peak RSS, leaving >5.3 GB headroom).
- **Zero Connectivity:** Fully self-contained local weights with zero external network or telemetry calls during inference.

---

## Benchmarks

| Metric                                 | Value                                                 |
| -------------------------------------- | ----------------------------------------------------- |
| Machine                                | Standard Laptop Profile (4 Cores CPU-only / 8 GB RAM) |
| Model Format                           | GGUF Q4_K_M (941 MB)                                  |
| RAM at Peak (RSS)                      | 1,692.58 MB (1.65 GB / 7.0 GB budget)                 |
| Remaining RAM Headroom                 | 5.35 GB (76.4% memory saved)                          |
| Generation Speed                       | 8.59 t/s (CPU-only on 4 threads)                      |
| Efficiency Score ($S_{\text{eff}}$)    | **76.39 / 100**                                       |
| Thermal Penalty ($P_{\text{thermal}}$) | **0 points** (No throttling, stable load)             |

These are measured development benchmarks. Official scores are verified by the ADTC profiler on the standard evaluation machine.

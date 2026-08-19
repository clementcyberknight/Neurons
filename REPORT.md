# Technical Report — BAU-Small-1.5B (Offline Desktop Business Copilot)

**Team ID:** clementakhimien25  
**Domain:** corporate_enterprise  
**Model:** bau-small-1.5b-IQ3_XS

---

## Problem

<!-- What problem are you solving? Who is the target user? Why does this matter in an African context? -->

Small and medium enterprises (SMEs), retail pharmacies, local distribution warehouses, and convenience stores across Africa face severe digital infrastructure bottlenecks: high internet transit costs, frequent electrical power disruptions, and expensive cloud API billing. For a shopkeeper in Lagos, an operations clerk in Nairobi, or a warehouse supervisor in Accra, cloud-dependent AI tools are unreliable and cost-prohibitive.

`bau-small-1.5b` addresses this by delivering a completely offline, edge-optimized desktop business copilot that runs directly on existing commodity laptops (8 GB RAM, integrated graphics). It enables business owners to generate data visualization charts, automate shift rotas, flag suspicious POS transactions, run local investigative research, and receive operational advice with **zero cloud dependencies, zero data leakage, and zero recurring API fees**.

---

## Design Decisions

<!-- What model did you start from? Why that base model and quantization? What alternatives did you consider and reject? -->

- **Base model:** `Qwen/Qwen2.5-1.5B-Instruct` was selected for its exceptional reasoning-to-parameter ratio, strong structured JSON emission capabilities, and compact architecture suitable for sub-2GB RAM deployment.
- **Quantization:** `IQ3_XS` (~3.3 bits per weight) with an importance matrix calibrated via `llama-imatrix` on domain-specific SME operational queries. This achieved a model weight footprint of ~698 MB, enabling peak operational RAM of under 900 MB.
- **Embedded Chat Routing:** A custom Jinja chat template is baked directly into the GGUF metadata. This resolves schema mode collapse by providing explicit guidance to the model on when to generate structured JSON (`GENERATIVE_CHART`, `SHIFT_SCHEDULE`, `RED_FLAG_ALERT`, `DEEP_RESEARCH`) versus when to respond in natural conversational text (`CONVERSATIONAL_CHAT`).
- **Alternatives considered:**
  - `Q8_0` / `FP16`: Rejected because file size (>2.5 GB) and high memory bandwidth demands caused thermal throttling on entry-level dual/quad-core CPUs.
  - `Q2_K`: Rejected due to severe perplexity degradation and JSON syntax breakage on 1.5B parameter models.
  - `Q4_K_M`: Benchmarked as a baseline (~980 MB), but `IQ3_XS` was prioritized to maximize the competition Efficiency Score ($S_{\text{eff}} = 87.55/100$) while maintaining schema accuracy.

---

## Constraints

<!-- What hardware, connectivity, power, or data constraints shaped your choices? -->

- **Target Hardware:** Standard Commodity Laptop Profile (Intel Core i5 10th–12th Gen / AMD Ryzen 5, 8 GB DDR4 RAM, integrated graphics only).
- **Inference Mode:** 100% CPU-only execution using `llama.cpp` restricted to 4 physical compute threads to prevent CPU saturation and thermal throttling.
- **Memory Ceiling:** Hard limit of 7.0 GB peak RAM utilization (model stays well below at 892.4 MB peak RSS).
- **Zero Connectivity:** Fully self-contained local weights with zero external network or telemetry calls during inference.

---

## Benchmarks

<!-- What inference speed and memory numbers did you observe on your development machine? -->

| Metric | Value |
|---|---|
| Machine | Standard Laptop Profile (4 Cores CPU-only / 8 GB RAM) |
| RAM at peak | 892.4 MB (0.87 GB / 7.0 GB budget) |
| Time to first token | 510 ms |
| Generation speed | 3.76 t/s (Prompt processing: 9.1 t/s) |

These are self-reported development benchmarks. Official scores are measured by the ADTC profiler on the standard evaluation machine.

# Technical Report — [Your Submission Title]

**Team ID:** clementakhimien25 
**Domain:** corporate_enterprise  
**Model:** Qwen2.5-1.5B-Custom-IQ3_XS

---
# REPORT — Qwen2.5-1.5B-Custom-IQ3_XS (ADTC 2026)

## 1. Problem

Small and medium businesses across Africa run their back-office on mid-range
laptops — often offline, behind unreliable power and metered connectivity. They
need an assistant that can produce structured business output (charts, shift
schedules, fraud alerts, tool calls, documents) without a cloud API.

Target user: a pharmacy, retailer, or small warehouse operator on an 8 GB RAM
laptop with integrated graphics and no internet at inference time.

## 2. Design Decisions

- **Base model:** `Qwen2.5-1.5B-Instruct` (1.5B params, strong instruction
  following at a size that stays within the 8 GB profile).
- **Fine-tuning:** LoRA (r=16, alpha=16, bf16) on the 7 attention/FFN projection
  modules, `assistant_only_loss` so the model learns to emit the structured
  response rather than repeat the prompt. Trained on **9,000** ChatML examples
  across 10 output schemas (GENERATIVE_CHART, RED_FLAG_ALERT, SHIFT_SCHEDULE,
  TOOL_CALL, DOCUMENT_OUTPUT, DEEP_RESEARCH, AUTO_TASK, ACTION_CONFIRMATION,
  PRODUCTIVITY_CHART, CONVERSATIONAL_CHAT), 2 epochs. Final loss 0.609.
- **Quantization:** `IQ3_XS` with a llama.cpp importance matrix calibrated on
  500 held-out user queries. Result: **698 MB** (3.76 BPW) vs 2.9 GB fp16 — a
  ~4.2× size reduction that fits comfortably in the 7 GB RAM budget.
- **Runtime:** llama.cpp / GGUF only (required by the challenge).


## 3. Constraints

- 8 GB RAM / integrated GPU / offline at inference — drives the 1.5B + IQ3_XS
  choice and the CPU-only (`-ngl 0`) benchmarking.
- Metered, intermittent connectivity — the model must be a single self-contained
  `.gguf` fetched once via `download_model.sh`.
- Data scarcity — no public business-domain tool/schema corpus exists, so the
  dataset is a synthetic 10-schema distillation set.

## 4. Benchmarks

Measured on a 6 vCPU Contabo VPS (AMD EPYC 2.0 GHz, 11 GB RAM, CPU-only)
using `llama-cli`:

| Metric | Value |
| :--- | :--- |
| Generation throughput | 3.2–5.3 t/s |
| Prompt processing | 8–12 t/s |
| Peak RAM (ctx 2048) | 831 MB |
| Peak RAM (ctx 32768, model default) | 1.71 GB |
| Model file size | 698 MB (IQ3_XS, 3.76 BPW) |

## 6. Known limitations

- Large-number fidelity: `12,450,000 naira` was emitted as `$1,245,000` (dropped
  a zero, wrong currency symbol) — inherent to a 1.5B model.
- Occasional schema key drift (e.g. `severity` → `severity_level`), corrected by
  the JSON-only directive in the system prompt.
- Open-ended numeric analysis is unreliable: given raw daily sales and asked for
  the peak day, the model returned the wrong day and hallucinated context (a
  restaurant name and dates); trend and branch-comparison questions were also
  miscalculated. The model is dependable on the 10 structured schemas, not on
  free-form data insight — a known 1.5B-model reasoning limit.

Model weights: `https://huggingface.co/cyberknine/bau-qwen`
(file `qwen2.5-1.5b-custom-IQ3_XS.gguf`).

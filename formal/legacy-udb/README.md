# Legacy UDB/IDL snapshot

This directory is a historical, non-normative snapshot of the generated
UDB/IDL material that preceded the traditional prose instruction description.
It is not included by `src/riscv-spec.adoc`, is not a second source of ISA
semantics, and must not be updated to track the published specification.

Snapshot source:

- Repository: `riscv/riscv-attached-matrix-extension`
- Baseline commit: `b97c6c4656525ee06aeb9600021b1debc0a76233`
- Baseline tag: `v0.5`

The snapshot is intentionally not self-contained. Its purpose is provenance
and migration review; buildable normative content lives under `src/`.

## Frozen files

| File | SHA-256 |
|---|---|
| `instructions-idl.adoc` | `7e103b393e5e6e7e762757b890d7afa9a51eca3b4a046567803e807070d49680` |
| `functions-idl.adoc` | `140e50c2d5bb24f5de88fec1a71ac15c29cc2b6f8084d084cfd7024c3d8c1b07` |
| `instruction-encoding-allocations.adoc` | `9a3748a14613d05e44c7a70810f0b1747df2c75125e46e98ed0725fada929f30` |

The Git history records the prose-cutover review and subsequent semantic
changes. This snapshot remains frozen and is not a maintenance copy of the
published specification.

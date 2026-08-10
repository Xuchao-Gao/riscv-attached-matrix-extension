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
| `instructions-idl.adoc` | `9dab6e7c5d6979305bc15ea8537f28c9c5ef8c9d7cf7adc18a1a3dd5374f323f` |
| `functions-idl.adoc` | `ffb92d0b1147f9bcf3c3358c930850333b0fcaacd9ae1239a7538f7253e1c75d` |
| `instruction-encoding-allocations.adoc` | `9a3748a14613d05e44c7a70810f0b1747df2c75125e46e98ed0725fada929f30` |

Semantic conflicts and their prose dispositions are recorded in
`docs/migration/ame-prose-migration-audit.md`.

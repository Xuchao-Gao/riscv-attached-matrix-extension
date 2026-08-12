# AME prose migration audit

Baseline: `b97c6c4656525ee06aeb9600021b1debc0a76233` (`v0.5`).

The published prose is authoritative after cutover. NumPy examples are never semantic authority. A correction is permitted only when the legacy text is self-contradictory or is the sole outlier against the instruction description, programming model, and family contract. Any two plausible architectural behaviors block cutover until the specification reviewers resolve them.

## Instruction coverage (141/141)

| Instruction | Legacy line | Anchor | Category | Mnemonic | Architectural operation | Required common contract | Correction | Status |
|---|---:|---|---|---|---|---|---|---|
| `ame.acquire` | 401 | `ame:doc:inst:ame_acquire` | Resource Management | `ame.acquire rd, rs1` | `X[rd] = acquire_backend(descriptor = X[rs1])` | `ame-common-state-access` | - | Ready |
| `ame.release` | 438 | `ame:doc:inst:ame_release` | Resource Management | `ame.release` | `release_backend()` | `ame-common-state-access` | - | Ready |
| `agettyp` | 469 | `ame:doc:inst:agettyp` | Datatype Management | `agettyp rd, ad` | `X[rd] = zero_extend_XLEN(Ad[ad])` | `ame-common-datatype-support` | - | Ready |
| `asettyp` | 511 | `ame:doc:inst:asettyp` | Datatype Management | `asettyp ad, rs1` | `Ad[ad] = X[rs1][31:0]; raw_bits(Acc[ad]) = 0` | `ame-common-datatype-support` | - | Ready |
| `mabs.ew` | 564 | `ame:doc:inst:mabs_ew` | Elementwise Arithmetic | `mabs.ew md, ms1` | `D[i] = \\|A[i]\\|` | `ame-common-arithmetic` | - | Ready |
| `mabsdiff.ew` | 645 | `ame:doc:inst:mabsdiff_ew` | Elementwise Arithmetic | `mabsdiff.ew md, ms1, ms2` | `D[i] = \\|A[i] - B[i]\\|` | `ame-common-arithmetic` | - | Ready |
| `mabsdiff.ew.x` | 743 | `ame:doc:inst:mabsdiff_ew_x` | Elementwise Arithmetic | `mabsdiff.ew.x md, rs1, ms2` | `D[i] = \\|c - B[i]\\|` | `ame-common-arithmetic` | - | Ready |
| `madd.ew` | 836 | `ame:doc:inst:madd_ew` | Elementwise Arithmetic | `madd.ew md, ms1, ms2` | `D[i] = A[i] + B[i]` | `ame-common-arithmetic` | AME-MIG-001 | Ready |
| `madd.ew.x` | 933 | `ame:doc:inst:madd_ew_x` | Elementwise Arithmetic | `madd.ew.x md, rs1, ms2` | `D[i] = c + B[i]` | `ame-common-arithmetic` | - | Ready |
| `mand.ew` | 1026 | `ame:doc:inst:mand_ew` | Bitwise | `mand.ew md, ms1, ms2` | `D[i] = A[i] & B[i]` | `ame-common-arithmetic` | - | Ready |
| `mand.ew.x` | 1123 | `ame:doc:inst:mand_ew_x` | Bitwise | `mand.ew.x md, rs1, ms2` | `D[i] = c & B[i]` | `ame-common-arithmetic` | - | Ready |
| `mandnot.ew` | 1216 | `ame:doc:inst:mandnot_ew` | Bitwise | `mandnot.ew md, ms1, ms2` | `D[i] = A[i] & ~B[i]` | `ame-common-arithmetic` | - | Ready |
| `mandnot.ew.x` | 1315 | `ame:doc:inst:mandnot_ew_x` | Bitwise | `mandnot.ew.x md, rs1, ms2` | `D[i] = c & ~B[i]` | `ame-common-arithmetic` | - | Ready |
| `mcmovge.ew` | 1408 | `ame:doc:inst:mcmovge_ew` | Compare and Predication | `mcmovge.ew md, ms1, ms2` | `D[i] = (A[i] >= 0) ? B[i] : D[i]` | `ame-common-arithmetic` | - | Ready |
| `mcmovlt.ew` | 1514 | `ame:doc:inst:mcmovlt_ew` | Compare and Predication | `mcmovlt.ew md, ms1, ms2` | `D[i] = (A[i] < 0) ? B[i] : D[i]` | `ame-common-arithmetic` | - | Ready |
| `mcmpge.ew` | 1620 | `ame:doc:inst:mcmpge_ew` | Compare and Predication | `mcmpge.ew md, ms1, ms2` | `D[i] = (A[i] >= B[i]) ? -1 : 0` | `ame-common-arithmetic` | - | Ready |
| `mcmpge.ew.x` | 1724 | `ame:doc:inst:mcmpge_ew_x` | Compare and Predication | `mcmpge.ew.x md, rs1, ms2` | `D[i] = (c >= B[i]) ? -1 : 0` | `ame-common-arithmetic` | - | Ready |
| `mcmplt.ew` | 1818 | `ame:doc:inst:mcmplt_ew` | Compare and Predication | `mcmplt.ew md, ms1, ms2` | `D[i] = (A[i] < B[i]) ? -1 : 0` | `ame-common-arithmetic` | - | Ready |
| `mcmplt.ew.x` | 1922 | `ame:doc:inst:mcmplt_ew_x` | Compare and Predication | `mcmplt.ew.x md, rs1, ms2` | `D[i] = (c < B[i]) ? -1 : 0` | `ame-common-arithmetic` | - | Ready |
| `mcolbcast.ew.x` | 2016 | `ame:doc:inst:mcolbcast_ew_x` | Permutation | `mcolbcast.ew.x md, rs1, ms2` | `D[i,j] = A[i,c]` | `ame-common-structural` | - | Ready |
| `mcolgather.ew` | 2122 | `ame:doc:inst:mcolgather_ew` | Permutation | `mcolgather.ew md, ms1, ms2` | `D[i,j] = A[i, B[i,j]]` | `ame-common-structural` | - | Ready |
| `mcolid.ew` | 2240 | `ame:doc:inst:mcolid_ew` | State Management | `mcolid.ew md` | `D[i,j] = j` | `ame-common-register-groups` | - | Ready |
| `mcolshift.ew.x` | 2323 | `ame:doc:inst:mcolshift_ew_x` | Permutation | `mcolshift.ew.x md, rs1, ms2` | `D[i,j] = A[i, j+c]` | `ame-common-structural` | - | Ready |
| `mcolunzip.ew` | 2437 | `ame:doc:inst:mcolunzip_ew` | Permutation | `mcolunzip.ew ms1, ms2` | `ms1[i,j] = A[i,2j] + ms1[i, N/2+j] = B[i,2j] + ms2[i,j] = A[i,2j+1] + ms2[i, N/2+j] = B[i,2j+1]` | `ame-common-structural` | - | Ready |
| `mcolzip.ew` | 2535 | `ame:doc:inst:mcolzip_ew` | Permutation | `mcolzip.ew ms1, ms2` | `ms1[i,2j] = A[i,j] + ms1[i,2j+1] = B[i,j] + ms2[i,2j] = A[i, N/2+j] + ms2[i,2j+1] = B[i, N/2+j]` | `ame-common-structural` | - | Ready |
| `mconv.ew` | 2636 | `ame:doc:inst:mconv_ew` | Register move / data conversion | `mconv.ew md, ms1` | `D = convert(A) over the formed logical operand` | `ame-common-register-groups` | - | Ready |
| `mbcast.m.x` | 2755 | `ame:doc:inst:mbcast_m_x` | Register move / data conversion | `mbcast.m.x md, rs1, rs2` | `D[i] = CONV1D(X[rs1], X[rs2], Md[md])` | `ame-common-register-groups` | - | Ready |
| `mcos.ew` | 2835 | `ame:doc:inst:mcos_ew` | Elementwise Math Functions | `mcos.ew md, ms1` | `D[i] = cos(A[i])` | `ame-common-arithmetic` | - | Ready |
| `mexp2.ew` | 2930 | `ame:doc:inst:mexp2_ew` | Elementwise Math Functions | `mexp2.ew md, ms1` | `D[i] = 2^A[i]^` | `ame-common-arithmetic` | - | Ready |
| `mfrintm.ew` | 3013 | `ame:doc:inst:mfrintm_ew` | Elementwise Arithmetic | `mfrintm.ew md, ms1` | `D[i] = floor(A[i])` | `ame-common-arithmetic` | - | Ready |
| `mfrintn.ew` | 3102 | `ame:doc:inst:mfrintn_ew` | Elementwise Arithmetic | `mfrintn.ew md, ms1` | `D[i] = roundTiesToEven(A[i])` | `ame-common-arithmetic` | - | Ready |
| `mfrintp.ew` | 3191 | `ame:doc:inst:mfrintp_ew` | Elementwise Arithmetic | `mfrintp.ew md, ms1` | `D[i] = ceil(A[i])` | `ame-common-arithmetic` | - | Ready |
| `mfrintz.ew` | 3280 | `ame:doc:inst:mfrintz_ew` | Elementwise Arithmetic | `mfrintz.ew md, ms1` | `D[i] = trunc(A[i])` | `ame-common-arithmetic` | - | Ready |
| `mgettyp` | 3369 | `ame:doc:inst:mgettyp` | Datatype Management | `mgettyp rd, ms1` | `X[rd] = zero_extend_XLEN(Md[ms1])` | `ame-common-datatype-support` | - | Ready |
| `mhdiff.ew` | 3415 | `ame:doc:inst:mhdiff_ew` | Elementwise Arithmetic | `mhdiff.ew md, ms1, ms2` | `D[i] = (B[i] - A[i]) / 2` | `ame-common-arithmetic` | - | Ready |
| `mhdiff.ew.x` | 3513 | `ame:doc:inst:mhdiff_ew_x` | Elementwise Arithmetic | `mhdiff.ew.x md, rs1, ms2` | `D[i] = (c - B[i]) / 2` | `ame-common-arithmetic` | - | Ready |
| `mldexp.ew` | 3606 | `ame:doc:inst:mldexp_ew` | Elementwise Math Functions | `mldexp.ew md, ms1, ms2` | `D[i] = A[i] × 2^B[i]^` | `ame-common-arithmetic` | - | Ready |
| `mldexp.ew.x` | 3708 | `ame:doc:inst:mldexp_ew_x` | Elementwise Math Functions | `mldexp.ew.x md, rs1, ms2` | `D[i] = B[i] × 2^c^` | `ame-common-arithmetic` | AME-MIG-006 | Ready |
| `mldexpacc.ew` | 3809 | `ame:doc:inst:mldexpacc_ew` | Elementwise Math Functions | `mldexpacc.ew md, ms1, ms2` | `D[i] = D[i] + A[i] × 2^B[i]^` | `ame-common-arithmetic` | - | Ready |
| `mldexpacc.ew.x` | 3913 | `ame:doc:inst:mldexpacc_ew_x` | Elementwise Math Functions | `mldexpacc.ew.x md, rs1, ms2` | `D[i] = D[i] + B[i] × 2^c^` | `ame-common-arithmetic` | AME-MIG-006 | Ready |
| `mlog2.ew` | 4016 | `ame:doc:inst:mlog2_ew` | Elementwise Math Functions | `mlog2.ew md, ms1` | `D[i] = log~2~(A[i])` | `ame-common-arithmetic` | - | Ready |
| `mlog2sub.ew` | 4099 | `ame:doc:inst:mlog2sub_ew` | Elementwise Math Functions | `mlog2sub.ew md, ms1, ms2` | `D[i] = log~2~(\\|A[i]\\|) - B[i]` | `ame-common-arithmetic` | - | Ready |
| `mlog2sub.ew.x` | 4202 | `ame:doc:inst:mlog2sub_ew_x` | Elementwise Math Functions | `mlog2sub.ew.x md, rs1, ms2` | `D[i] = log~2~(\\|B[i]\\|) - c` | `ame-common-arithmetic` | - | Ready |
| `mls` | 4298 | `ame:doc:inst:mls` | Memory | `mls md, rs1` | `md <= mem[rs1]` | `ame-common-memory` | AME-MIG-002, AME-MIG-007 | Ready |
| `mls.cm` | 4364 | `ame:doc:inst:mls_cm` | Memory | `mls.cm md, rs1` | `md <= mem[rs1]` | `ame-common-memory` | AME-MIG-002 | Ready |
| `mls.rm` | 4446 | `ame:doc:inst:mls_rm` | Memory | `mls.rm md, rs1` | `md <= mem[rs1]` | `ame-common-memory` | AME-MIG-002 | Ready |
| `mls.st` | 4528 | `ame:doc:inst:mls_st` | Memory | `mls.st md, (rs1), rs2` | `md <= mem[rs1, stride=rs2]` | `ame-common-memory` | AME-MIG-002 | Ready |
| `mls.tst` | 4629 | `ame:doc:inst:mls_tst` | Memory | `mls.tst md, (rs1), rs2` | `md <= mem[rs1, stride=rs2]` | `ame-common-memory` | AME-MIG-002 | Ready |
| `mmax.ew` | 4728 | `ame:doc:inst:mmax_ew` | Elementwise Arithmetic | `mmax.ew md, ms1, ms2` | `D[i] = max(A[i], B[i])` | `ame-common-arithmetic` | - | Ready |
| `mmax.ew.x` | 4826 | `ame:doc:inst:mmax_ew_x` | Elementwise Arithmetic | `mmax.ew.x md, rs1, ms2` | `D[i] = max(c, B[i])` | `ame-common-arithmetic` | - | Ready |
| `mmean.ew` | 4919 | `ame:doc:inst:mmean_ew` | Elementwise Arithmetic | `mmean.ew md, ms1, ms2` | `D[i] = (A[i] + B[i]) / 2` | `ame-common-arithmetic` | - | Ready |
| `mmean.ew.x` | 5017 | `ame:doc:inst:mmean_ew_x` | Elementwise Arithmetic | `mmean.ew.x md, rs1, ms2` | `D[i] = (c + B[i]) / 2` | `ame-common-arithmetic` | - | Ready |
| `mmin.ew` | 5110 | `ame:doc:inst:mmin_ew` | Elementwise Arithmetic | `mmin.ew md, ms1, ms2` | `D[i] = min(A[i], B[i])` | `ame-common-arithmetic` | - | Ready |
| `mmin.ew.x` | 5208 | `ame:doc:inst:mmin_ew_x` | Elementwise Arithmetic | `mmin.ew.x md, rs1, ms2` | `D[i] = min(c, B[i])` | `ame-common-arithmetic` | - | Ready |
| `mmov.m.a` | 5301 | `ame:doc:inst:mmov_m_a` | State Management | `mmov.m.a md, acc` | `D[i] = acc[i]` | `ame-common-register-groups` | - | Ready |
| `mmov.a.m` | 5423 | `ame:doc:inst:mmov_a_m` | State Management | `mmov.a.m acc, ms` | `acc[i] = A[i]` | `ame-common-register-groups` | - | Ready |
| `mmov.m.m` | 5542 | `ame:doc:inst:mmov_m_m` | State Management | `mmov.m.m md, ms` | `D[i] = A[i]` | `ame-common-register-groups` | - | Ready |
| `mmove8.m.x` | 5622 | `ame:doc:inst:mmove8_m_x` | Register move / data conversion | `mmove8.m.x md, rs2, rs1` | `D.rm[pos, 8] = X[rs2][7:0]` | `ame-common-register-groups` | - | Ready |
| `mmove16.m.x` | 5705 | `ame:doc:inst:mmove16_m_x` | Register move / data conversion | `mmove16.m.x md, rs2, rs1` | `D.rm[pos, 16] = X[rs2][15:0]` | `ame-common-register-groups` | - | Ready |
| `mmove32.m.x` | 5788 | `ame:doc:inst:mmove32_m_x` | Register move / data conversion | `mmove32.m.x md, rs2, rs1` | `D.rm[pos, 32] = X[rs2][31:0]` | `ame-common-register-groups` | - | Ready |
| `mmove64.m.x` | 5871 | `ame:doc:inst:mmove64_m_x` | Register move / data conversion | `mmove64.m.x md, rs2, rs1` | `D.rm[pos, 64] = X[rs2][63:0]` | `ame-common-register-groups` | - | Ready |
| `mmove8.x.m` | 5960 | `ame:doc:inst:mmove8_x_m` | Register move / data conversion | `mmove8.x.m rd, ms2, rs1` | `X[rd] = zero_extend(A.rm[pos, 8])` | `ame-common-register-groups` | - | Ready |
| `mmove16.x.m` | 6043 | `ame:doc:inst:mmove16_x_m` | Register move / data conversion | `mmove16.x.m rd, ms2, rs1` | `X[rd] = zero_extend(A.rm[pos, 16])` | `ame-common-register-groups` | - | Ready |
| `mmove32.x.m` | 6126 | `ame:doc:inst:mmove32_x_m` | Register move / data conversion | `mmove32.x.m rd, ms2, rs1` | `X[rd] = zero_extend(A.rm[pos, 32])` | `ame-common-register-groups` | - | Ready |
| `mmove64.x.m` | 6209 | `ame:doc:inst:mmove64_x_m` | Register move / data conversion | `mmove64.x.m rd, ms2, rs1` | `X[rd] = zero_extend(A.rm[pos, 64])` | `ame-common-register-groups` | - | Ready |
| `mmul.2d` | 6298 | `ame:doc:inst:mmul_2d` | Matrix Multiply | `mmul.2d acc, ms1, ms2` | `C = A × B` | `ame-common-matmul` | AME-MIG-003 | Ready |
| `mmul.ew` | 6399 | `ame:doc:inst:mmul_ew` | Elementwise Arithmetic | `mmul.ew md, ms1, ms2` | `D[i] = A[i] × B[i]` | `ame-common-arithmetic` | - | Ready |
| `mmul.ew.x` | 6496 | `ame:doc:inst:mmul_ew_x` | Elementwise Arithmetic | `mmul.ew.x md, rs1, ms2` | `D[i] = c × B[i]` | `ame-common-arithmetic` | - | Ready |
| `mmulacc.2d` | 6589 | `ame:doc:inst:mmulacc_2d` | Matrix Multiply | `mmulacc.2d acc, ms1, ms2` | `C = C + A × B` | `ame-common-matmul` | - | Ready |
| `mmulacc.ew` | 6696 | `ame:doc:inst:mmulacc_ew` | Elementwise Arithmetic | `mmulacc.ew md, ms1, ms2` | `D[i] = D[i] + A[i] × B[i]` | `ame-common-arithmetic` | - | Ready |
| `mmulacc.ew.x` | 6801 | `ame:doc:inst:mmulacc_ew_x` | Elementwise Arithmetic | `mmulacc.ew.x md, rs1, ms2` | `D[i] = D[i] + c × B[i]` | `ame-common-arithmetic` | - | Ready |
| `mmulaccneg.2d` | 6897 | `ame:doc:inst:mmulaccneg_2d` | Matrix Multiply | `mmulaccneg.2d acc, ms1, ms2` | `C = C - A × B` | `ame-common-matmul` | - | Ready |
| `mmulaccneg.ew` | 7003 | `ame:doc:inst:mmulaccneg_ew` | Elementwise Arithmetic | `mmulaccneg.ew md, ms1, ms2` | `D[i] = D[i] - A[i] × B[i]` | `ame-common-arithmetic` | - | Ready |
| `mmulaccneg.ew.x` | 7108 | `ame:doc:inst:mmulaccneg_ew_x` | Elementwise Arithmetic | `mmulaccneg.ew.x md, rs1, ms2` | `D[i] = D[i] - c × B[i]` | `ame-common-arithmetic` | - | Ready |
| `mmuladd.ew` | 7204 | `ame:doc:inst:mmuladd_ew` | Elementwise Arithmetic | `mmuladd.ew md, ms1, ms2` | `D[i] = A[i] + B[i] × D[i]` | `ame-common-arithmetic` | - | Ready |
| `mmuladd.ew.x` | 7309 | `ame:doc:inst:mmuladd_ew_x` | Elementwise Arithmetic | `mmuladd.ew.x md, rs1, ms2` | `D[i] = c + B[i] × D[i]` | `ame-common-arithmetic` | - | Ready |
| `mmulat.2d` | 7405 | `ame:doc:inst:mmulat_2d` | Matrix Multiply | `mmulat.2d acc, ms1, ms2` | `C = Σ~s~ A_s^T^ × B_s` | `ame-common-matmul` | AME-MIG-003, AME-MIG-005 | Ready |
| `mmulatacc.2d` | 7506 | `ame:doc:inst:mmulatacc_2d` | Matrix Multiply | `mmulatacc.2d acc, ms1, ms2` | `C = C + Σ~s~ A_s^T^ × B_s` | `ame-common-matmul` | AME-MIG-005 | Ready |
| `mmulbt.2d` | 7612 | `ame:doc:inst:mmulbt_2d` | Matrix Multiply | `mmulbt.2d acc, ms1, ms2` | `C = Σ~s~ A_s × B_s^T^` | `ame-common-matmul` | AME-MIG-003, AME-MIG-005 | Ready |
| `mmulbtacc.2d` | 7713 | `ame:doc:inst:mmulbtacc_2d` | Matrix Multiply | `mmulbtacc.2d acc, ms1, ms2` | `C = C + Σ~s~ A_s × B_s^T^` | `ame-common-matmul` | AME-MIG-005 | Ready |
| `mmulneg.2d` | 7819 | `ame:doc:inst:mmulneg_2d` | Matrix Multiply | `mmulneg.2d acc, ms1, ms2` | `C = -(A × B)` | `ame-common-matmul` | AME-MIG-003 | Ready |
| `mmulneg.ew` | 7920 | `ame:doc:inst:mmulneg_ew` | Elementwise Arithmetic | `mmulneg.ew md, ms1, ms2` | `D[i] = -(A[i] × B[i])` | `ame-common-arithmetic` | - | Ready |
| `mmulneg.ew.x` | 8021 | `ame:doc:inst:mmulneg_ew_x` | Elementwise Arithmetic | `mmulneg.ew.x md, rs1, ms2` | `D[i] = -(c × B[i])` | `ame-common-arithmetic` | - | Ready |
| `mmulsub.ew` | 8114 | `ame:doc:inst:mmulsub_ew` | Elementwise Arithmetic | `mmulsub.ew md, ms1, ms2` | `D[i] = A[i] - B[i] × D[i]` | `ame-common-arithmetic` | - | Ready |
| `mmulsub.ew.x` | 8220 | `ame:doc:inst:mmulsub_ew_x` | Elementwise Arithmetic | `mmulsub.ew.x md, rs1, ms2` | `D[i] = c - B[i] × D[i]` | `ame-common-arithmetic` | - | Ready |
| `mor.ew` | 8317 | `ame:doc:inst:mor_ew` | Bitwise | `mor.ew md, ms1, ms2` | `D[i] = A[i] \\| B[i]` | `ame-common-arithmetic` | - | Ready |
| `mor.ew.x` | 8414 | `ame:doc:inst:mor_ew_x` | Bitwise | `mor.ew.x md, rs1, ms2` | `D[i] = c \\| B[i]` | `ame-common-arithmetic` | - | Ready |
| `mornot.ew` | 8507 | `ame:doc:inst:mornot_ew` | Bitwise | `mornot.ew md, ms1, ms2` | `D[i] = A[i] \\| ~B[i]` | `ame-common-arithmetic` | - | Ready |
| `mornot.ew.x` | 8606 | `ame:doc:inst:mornot_ew_x` | Bitwise | `mornot.ew.x md, rs1, ms2` | `D[i] = c \\| ~B[i]` | `ame-common-arithmetic` | - | Ready |
| `mpack.ew.x` | 8699 | `ame:doc:inst:mpack_ew_x` | Register move / data conversion | `mpack.ew.x md, rs1, ms2` | `D[k] = convert(A)` | `ame-common-register-groups` | - | Ready |
| `mprefixadd.col` | 8794 | `ame:doc:inst:mprefixadd_col` | Reduction | `mprefixadd.col md, ms1` | `D[i,j] = Σ~k≤i~ A[k,j]` | `ame-common-structural` | - | Ready |
| `mprefixadd.row` | 8892 | `ame:doc:inst:mprefixadd_row` | Reduction | `mprefixadd.row md, ms1` | `D[i,j] = Σ~k≤j~ A[i,k]` | `ame-common-structural` | - | Ready |
| `mprefixmax.col` | 8990 | `ame:doc:inst:mprefixmax_col` | Reduction | `mprefixmax.col md, ms1` | `D[i,j] = max~k≤i~(A[k,j])` | `ame-common-structural` | - | Ready |
| `mprefixmax.row` | 9088 | `ame:doc:inst:mprefixmax_row` | Reduction | `mprefixmax.row md, ms1` | `D[i,j] = max~k≤j~(A[i,k])` | `ame-common-structural` | - | Ready |
| `mrdexp.ew` | 9186 | `ame:doc:inst:mrdexp_ew` | Elementwise Math Functions | `mrdexp.ew md, ms1, ms2` | `D[i] = A[i] × 2^-B[i]^` | `ame-common-arithmetic` | - | Ready |
| `mrdexpacc.ew` | 9288 | `ame:doc:inst:mrdexpacc_ew` | Elementwise Math Functions | `mrdexpacc.ew md, ms1, ms2` | `D[i] = D[i] + A[i] × 2^-B[i]^` | `ame-common-arithmetic` | - | Ready |
| `mrec.ew` | 9393 | `ame:doc:inst:mrec_ew` | Elementwise Math Functions | `mrec.ew md, ms1` | `D[i] = 1 / A[i]` | `ame-common-arithmetic` | - | Ready |
| `mreduceadd.col` | 9488 | `ame:doc:inst:mreduceadd_col` | Reduction | `mreduceadd.col md, ms1` | `D[:,j] = Σ~k~ A[k,j]` | `ame-common-structural` | - | Ready |
| `mreduceadd.row` | 9589 | `ame:doc:inst:mreduceadd_row` | Reduction | `mreduceadd.row md, ms1` | `D[i,:] = Σ~k~ A[i,k]` | `ame-common-structural` | - | Ready |
| `mreducemax.col` | 9690 | `ame:doc:inst:mreducemax_col` | Reduction | `mreducemax.col md, ms1` | `D[:,j] = max~k~(A[k,j])` | `ame-common-structural` | - | Ready |
| `mreducemax.row` | 9791 | `ame:doc:inst:mreducemax_row` | Reduction | `mreducemax.row md, ms1` | `D[i,:] = max~k~(A[i,k])` | `ame-common-structural` | - | Ready |
| `mreducemin.col` | 9892 | `ame:doc:inst:mreducemin_col` | Reduction | `mreducemin.col md, ms1` | `D[:,j] = min~k~(A[k,j])` | `ame-common-structural` | - | Ready |
| `mreducemin.row` | 9996 | `ame:doc:inst:mreducemin_row` | Reduction | `mreducemin.row md, ms1` | `D[i,:] = min~k~(A[i,k])` | `ame-common-structural` | - | Ready |
| `mrowbcast.ew.x` | 10100 | `ame:doc:inst:mrowbcast_ew_x` | Permutation | `mrowbcast.ew.x md, rs1, ms2` | `D[i,j] = A[c,j]` | `ame-common-structural` | - | Ready |
| `mrowgather.ew` | 10206 | `ame:doc:inst:mrowgather_ew` | Permutation | `mrowgather.ew md, ms1, ms2` | `D[i,j] = A[B[i,j],j]` | `ame-common-structural` | - | Ready |
| `mrowid.ew` | 10324 | `ame:doc:inst:mrowid_ew` | State Management | `mrowid.ew md` | `D[i,j] = i` | `ame-common-register-groups` | - | Ready |
| `mrowshift.ew.x` | 10407 | `ame:doc:inst:mrowshift_ew_x` | Permutation | `mrowshift.ew.x md, rs1, ms2` | `D[i,j] = A[i+c,j]` | `ame-common-structural` | - | Ready |
| `mrowunzip.ew` | 10518 | `ame:doc:inst:mrowunzip_ew` | Permutation | `mrowunzip.ew ms1, ms2` | `ms1[k,j] = A[2k,j] + ms1[k+N/2,j] = B[2k,j] + ms2[k,j] = A[2k+1,j] + ms2[k+N/2,j] = B[2k+1,j]` | `ame-common-structural` | AME-MIG-004 | Ready |
| `mrowzip.ew` | 10629 | `ame:doc:inst:mrowzip_ew` | Permutation | `mrowzip.ew ms1, ms2` | `ms1[2k,j] = A[k,j] + ms1[2k+1,j] = B[k,j] + ms2[2k,j] = A[N/2+k,j] + ms2[2k+1,j] = B[N/2+k,j]` | `ame-common-structural` | AME-MIG-004 | Ready |
| `mrsqrt.ew` | 10756 | `ame:doc:inst:mrsqrt_ew` | Elementwise Math Functions | `mrsqrt.ew md, ms1` | `D[i] = 1 / sqrt(A[i])` | `ame-common-arithmetic` | - | Ready |
| `mrowscatadd.ew` | 10851 | `ame:doc:inst:mrowscatadd_ew` | Permutation | `mrowscatadd.ew md, ms1, ms2` | `D[B[i,j], j] += A[i,j]` | `ame-common-structural` | - | Ready |
| `mcolscatadd.ew` | 10970 | `ame:doc:inst:mcolscatadd_ew` | Permutation | `mcolscatadd.ew md, ms1, ms2` | `D[i, B[i,j]] += A[i,j]` | `ame-common-structural` | - | Ready |
| `mrowscatmax.ew` | 11089 | `ame:doc:inst:mrowscatmax_ew` | Permutation | `mrowscatmax.ew md, ms1, ms2` | `D[B[i,j], j] = max(D[B[i,j],j], A[i,j])` | `ame-common-structural` | - | Ready |
| `mcolscatmax.ew` | 11208 | `ame:doc:inst:mcolscatmax_ew` | Permutation | `mcolscatmax.ew md, ms1, ms2` | `D[i, B[i,j]] = max(D[i,B[i,j]], A[i,j])` | `ame-common-structural` | - | Ready |
| `mselge.ew` | 11327 | `ame:doc:inst:mselge_ew` | Compare and Predication | `mselge.ew md, ms1, ms2` | `D[i] = (A[i] >= 0) ? B[i] : 0` | `ame-common-arithmetic` | - | Ready |
| `msellt.ew` | 11433 | `ame:doc:inst:msellt_ew` | Compare and Predication | `msellt.ew md, ms1, ms2` | `D[i] = (A[i] < 0) ? B[i] : 0` | `ame-common-arithmetic` | - | Ready |
| `msettyp` | 11539 | `ame:doc:inst:msettyp` | Datatype Management | `msettyp md, rs1` | `new_dtype = X[rs1][31:0]; Md[md] = new_dtype; raw_bits(M[md .. md+group_size-1]) = 0` | `ame-common-datatype-support` | - | Ready |
| `msin.ew` | 11606 | `ame:doc:inst:msin_ew` | Elementwise Math Functions | `msin.ew md, ms1` | `D[i] = sin(A[i])` | `ame-common-arithmetic` | - | Ready |
| `msll.ew` | 11701 | `ame:doc:inst:msll_ew` | Bitwise | `msll.ew md, ms1, ms2` | `D[i] = A[i] << (B[i] mod EW)` | `ame-common-arithmetic` | - | Ready |
| `msll.ew.x` | 11811 | `ame:doc:inst:msll_ew_x` | Bitwise | `msll.ew.x md, rs1, ms2` | `D[i] = B[i] << (c mod EW)` | `ame-common-arithmetic` | - | Ready |
| `msqrt.ew` | 11910 | `ame:doc:inst:msqrt_ew` | Elementwise Math Functions | `msqrt.ew md, ms1` | `D[i] = sqrt(A[i])` | `ame-common-arithmetic` | - | Ready |
| `msra.ew` | 12005 | `ame:doc:inst:msra_ew` | Bitwise | `msra.ew md, ms1, ms2` | `D[i] = A[i] >>s (B[i] mod EW)` | `ame-common-arithmetic` | - | Ready |
| `msra.ew.x` | 12115 | `ame:doc:inst:msra_ew_x` | Bitwise | `msra.ew.x md, rs1, ms2` | `D[i] = B[i] >>s (c mod EW)` | `ame-common-arithmetic` | - | Ready |
| `msrl.ew` | 12214 | `ame:doc:inst:msrl_ew` | Bitwise | `msrl.ew md, ms1, ms2` | `D[i] = A[i] >>u (B[i] mod EW)` | `ame-common-arithmetic` | - | Ready |
| `msrl.ew.x` | 12324 | `ame:doc:inst:msrl_ew_x` | Bitwise | `msrl.ew.x md, rs1, ms2` | `D[i] = B[i] >>u (c mod EW)` | `ame-common-arithmetic` | - | Ready |
| `mss` | 12423 | `ame:doc:inst:mss` | Memory | `mss ms1, rs1` | `mem[rs1] <= ms1` | `ame-common-memory` | AME-MIG-002, AME-MIG-007 | Ready |
| `mss.cm` | 12488 | `ame:doc:inst:mss_cm` | Memory | `mss.cm ms1, rs1` | `mem[rs1] <= ms1` | `ame-common-memory` | AME-MIG-002 | Ready |
| `mss.rm` | 12571 | `ame:doc:inst:mss_rm` | Memory | `mss.rm ms1, rs1` | `mem[rs1] <= ms1` | `ame-common-memory` | AME-MIG-002 | Ready |
| `mss.st` | 12654 | `ame:doc:inst:mss_st` | Memory | `mss.st ms1, (rs1), rs2` | `mem[rs1, stride=rs2] <= ms1` | `ame-common-memory` | AME-MIG-002 | Ready |
| `mss.tst` | 12754 | `ame:doc:inst:mss_tst` | Memory | `mss.tst ms1, (rs1), rs2` | `mem[rs1, stride=rs2] <= ms1` | `ame-common-memory` | AME-MIG-002 | Ready |
| `msub.ew` | 12852 | `ame:doc:inst:msub_ew` | Elementwise Arithmetic | `msub.ew md, ms1, ms2` | `D[i] = B[i] - A[i]` | `ame-common-arithmetic` | - | Ready |
| `msub.ew.x` | 12949 | `ame:doc:inst:msub_ew_x` | Elementwise Arithmetic | `msub.ew.x md, rs1, ms2` | `D[i] = c - B[i]` | `ame-common-arithmetic` | - | Ready |
| `msublog2.ew` | 13042 | `ame:doc:inst:msublog2_ew` | Elementwise Math Functions | `msublog2.ew md, ms1, ms2` | `D[i] = B[i] - log~2~(\\|A[i]\\|)` | `ame-common-arithmetic` | - | Ready |
| `msublog2.ew.x` | 13145 | `ame:doc:inst:msublog2_ew_x` | Elementwise Math Functions | `msublog2.ew.x md, rs1, ms2` | `D[i] = c - log~2~(\\|B[i]\\|)` | `ame-common-arithmetic` | - | Ready |
| `mtanh.ew` | 13241 | `ame:doc:inst:mtanh_ew` | Elementwise Math Functions | `mtanh.ew md, ms1` | `D[i] = tanh(A[i])` | `ame-common-arithmetic` | - | Ready |
| `munpack.ew.x` | 13336 | `ame:doc:inst:munpack_ew_x` | Register move / data conversion | `munpack.ew.x md, rs1, ms2` | `D = convert(A[k])` | `ame-common-register-groups` | - | Ready |
| `mxor.ew` | 13430 | `ame:doc:inst:mxor_ew` | Bitwise | `mxor.ew md, ms1, ms2` | `D[i] = A[i] ^ B[i]` | `ame-common-arithmetic` | - | Ready |
| `mxor.ew.x` | 13527 | `ame:doc:inst:mxor_ew_x` | Bitwise | `mxor.ew.x md, rs1, ms2` | `D[i] = c ^ B[i]` | `ame-common-arithmetic` | - | Ready |
| `mzero.2d.acc` | 13620 | `ame:doc:inst:mzero_2d_acc` | State Management | `mzero.2d.acc acc` | `C[i] = zero(Ad[acc])` | `ame-common-register-groups` | - | Ready |
| `mzero.2d.m` | 13676 | `ame:doc:inst:mzero_2d_m` | State Management | `mzero.2d.m md` | `D[i] = zero(Md[md])` | `ame-common-register-groups` | - | Ready |
| `fence.ame` | 13745 | `ame:doc:inst:fence_ame` | State Management | `fence.ame sw, sr, pw, pr` | `order AME predecessors pr/pw before non-AME successors sr/sw` | `ame-common-ordering` | - | Ready |

## Helper coverage (90/90)

| Legacy helper | Disposition | Target or rationale |
|---|---|---|
| `ame_effective_ms_enabled` | Migrate | `ame-common-state-access` |
| `ame_check_state_access` | Migrate | `ame-common-state-access` |
| `ame_acquire_backend` | Migrate | `ame-common-state-access` |
| `ame_release_backend` | Migrate | `ame-common-state-access` |
| `ame_datatype_supported` | Migrate | `ame-common-datatype-support` |
| `ame_op_supported` | Migrate | `ame-common-datatype-support` |
| `ame_scalar_op_supported` | Migrate | `ame-common-datatype-support` |
| `ame_scalar_data_value` | Migrate | `ame-common-datatype-support` |
| `ame_dtype_is_packed` | Migrate | `ame-common-datatype-support` |
| `ame_dtype_is_integer` | Migrate | `ame-common-datatype-support` |
| `ame_dtype_val_to_size` | Migrate | `ame-common-datatype-support` |
| `implemented?` | Delete | `standard RISC-V execution mechanism` |
| `mode` | Delete | `standard RISC-V execution mechanism` |
| `unpredictable` | Delete | `IDL execution detail` |
| `unreachable` | Delete | `IDL execution detail` |
| `exception_handling_mode` | Delete | `standard RISC-V execution mechanism` |
| `mtval_readonly?` | Delete | `standard RISC-V execution mechanism` |
| `mtval_for` | Delete | `standard RISC-V execution mechanism` |
| `stval_readonly?` | Delete | `standard RISC-V execution mechanism` |
| `stval_for` | Delete | `standard RISC-V execution mechanism` |
| `vstval_readonly?` | Delete | `standard RISC-V execution mechanism` |
| `vstval_for` | Delete | `standard RISC-V execution mechanism` |
| `notify_mode_change` | Delete | `standard RISC-V execution mechanism` |
| `implemented_version?` | Delete | `standard RISC-V execution mechanism` |
| `refresh_pending_interrupts` | Delete | `standard RISC-V execution mechanism` |
| `set_mode` | Delete | `standard RISC-V execution mechanism` |
| `abort_current_instruction` | Delete | `IDL execution detail` |
| `raise_precise` | Delete | `standard RISC-V execution mechanism` |
| `raise` | Delete | `standard RISC-V execution mechanism` |
| `ame_xform_impl_to_rm` | Migrate | `ame-common-register-groups` |
| `ame_read_m_element` | Migrate | `ame-common-register-groups` |
| `ame_matmul_accumulate` | Migrate | `ame-common-matmul` |
| `ame_stage_m_element_write` | Migrate | `ame-common-register-groups` |
| `ame_check_m_index` | Migrate | `ame-common-register-groups` |
| `ame_check_m_group` | Migrate | `ame-common-register-groups` |
| `ame_check_acc_index` | Migrate | `ame-common-register-groups` |
| `ame_stage_acc_element_write` | Migrate | `ame-common-register-groups` |
| `ame_stage_m_element_rmw` | Migrate | `ame-common-register-groups` |
| `ame_stage_m_element_op3` | Migrate | `ame-common-register-groups` |
| `ame_op` | Migrate | `ame-common-arithmetic` |
| `ame_op3` | Migrate | `ame-common-arithmetic` |
| `ame_xform_rm_to_impl` | Migrate | `ame-common-register-groups` |
| `sqrt` | Delete | `ordinary mathematical notation` |
| `min` | Delete | `ordinary mathematical notation` |
| `is_naturally_aligned` | Delete | `standard RISC-V execution mechanism` |
| `assert` | Delete | `IDL execution detail` |
| `mpv` | Delete | `standard RISC-V execution mechanism` |
| `effective_ldst_mode` | Delete | `standard RISC-V execution mechanism` |
| `cached_translation` | Delete | `standard RISC-V execution mechanism` |
| `current_translation_mode` | Delete | `standard RISC-V execution mechanism` |
| `xlen` | Delete | `standard RISC-V execution mechanism` |
| `tinst_value_for_guest_page_fault` | Delete | `standard RISC-V execution mechanism` |
| `raise_guest_page_fault` | Delete | `standard RISC-V execution mechanism` |
| `pma_applies?` | Delete | `standard RISC-V execution mechanism` |
| `direct_csr_lookup` | Delete | `standard RISC-V execution mechanism` |
| `csr_hw_read` | Delete | `standard RISC-V execution mechanism` |
| `csr_sw_read` | Delete | `standard RISC-V execution mechanism` |
| `pmp_match_64` | Delete | `standard RISC-V execution mechanism` |
| `pmp_match_32` | Delete | `standard RISC-V execution mechanism` |
| `pmp_match` | Delete | `standard RISC-V execution mechanism` |
| `pmp_check` | Delete | `standard RISC-V execution mechanism` |
| `access_check` | Delete | `standard RISC-V execution mechanism` |
| `read_physical_memory_32` | Delete | `standard RISC-V execution mechanism` |
| `read_physical_memory` | Delete | `standard RISC-V execution mechanism` |
| `atomic_check_then_write_32` | Delete | `standard RISC-V execution mechanism` |
| `gstage_page_walk` | Delete | `standard RISC-V execution mechanism` |
| `read_physical_memory_64` | Delete | `standard RISC-V execution mechanism` |
| `atomic_check_then_write_64` | Delete | `standard RISC-V execution mechanism` |
| `tinst_transform` | Delete | `standard RISC-V execution mechanism` |
| `translate_gstage` | Delete | `standard RISC-V execution mechanism` |
| `stage1_page_walk` | Delete | `standard RISC-V execution mechanism` |
| `maybe_cache_translation` | Delete | `standard RISC-V execution mechanism` |
| `translate` | Delete | `standard RISC-V execution mechanism` |
| `read_memory_aligned` | Delete | `standard RISC-V execution mechanism` |
| `in_naturally_aligned_region?` | Delete | `standard RISC-V execution mechanism` |
| `misaligned_is_atomic?` | Delete | `standard RISC-V execution mechanism` |
| `read_physical_memory_8` | Delete | `standard RISC-V execution mechanism` |
| `read_memory` | Delete | `standard RISC-V execution mechanism` |
| `read_physical_memory_16` | Delete | `standard RISC-V execution mechanism` |
| `read_memory_ame` | Migrate | `ame-common-memory` |
| `ame_xform_cm_to_impl` | Migrate | `ame-common-memory` |
| `ame_xform_impl_to_cm` | Migrate | `ame-common-memory` |
| `write_physical_memory` | Delete | `standard RISC-V execution mechanism` |
| `write_memory_aligned` | Delete | `standard RISC-V execution mechanism` |
| `write_physical_memory_8` | Delete | `standard RISC-V execution mechanism` |
| `write_memory` | Delete | `standard RISC-V execution mechanism` |
| `write_physical_memory_16` | Delete | `standard RISC-V execution mechanism` |
| `write_physical_memory_32` | Delete | `standard RISC-V execution mechanism` |
| `write_physical_memory_64` | Delete | `standard RISC-V execution mechanism` |
| `write_memory_ame` | Migrate | `ame-common-memory` |

## Published normative-anchor coverage (12/12)

| Normative anchor | Origin | Disposition |
|---|---|---|
| `norm:ame_nsq_1d` | Baseline programming model | Preserve on the ordinary elementwise operand-formation rule |
| `norm:ame_nsq_structural` | Baseline programming model | Preserve on the structural per-square rule |
| `norm:ame_nsq_matmul` | Baseline programming model | Preserve on the matrix-product operand-formation rule |
| `norm:ame_register_group_overlap` | Baseline programming model | Preserve on register-group overlap prose |
| `norm:ame_source_snapshot` | Baseline programming model | Preserve on pre-instruction source snapshot prose |
| `norm:ame_atomic_register_writeback` | Baseline programming model | Preserve on staged atomic writeback prose |
| `norm:ame_register_exception_atomicity` | Baseline programming model | Preserve on synchronous-exception atomicity prose |
| `norm:ame_op_supported_contract` | Legacy helper formal text | Preserve on prose under `ame-common-datatype-support` |
| `norm:ame_op_supported_defined_result` | Legacy helper formal text | Preserve on prose under `ame-common-datatype-support` |
| `norm:ame_op_precondition` | Legacy helper formal text | Preserve on prose under `ame-common-datatype-support` |
| `norm:ame_op_result_width` | Legacy helper formal text | Preserve on prose under `ame-common-datatype-support` |
| `norm:ame_fp_special_values` | Legacy helper formal text | Preserve on prose under `ame-common-arithmetic` |

## Corrections

### AME-MIG-001: `madd.ew` illustrative assignment target

- Before: the NumPy block assigns `ms1 = ms2 + ms1`.
- After: the normative operation is `D[i] = A[i] + B[i]`, writing `md`.
- Evidence: the mnemonic declares `md` as the destination; the Description says the result is stored in `md`; the programming-model operation table uses `D`; the IDL stages writes to `md`.
- Architectural impact: none; this corrects a non-normative illustrative typo.

### AME-MIG-002: AME memory-fault atomicity and fault address

- Before: the legacy byte-loop helpers could expose earlier byte stores before a later byte fault and passed the current byte or segment address to ordinary memory helpers.
- After: the pre-existing normative programming-model rule remains authoritative: a fault commits no memory or register location, and the reported fault address is the instruction base address.
- Evidence: baseline `src/programming_model.adoc` lines 1313-1317 explicitly require no partial completion and the base fault address; the legacy instruction chapter states that common programming-model rules override shorthand operation detail.
- Architectural impact: the published architecture is unchanged, but a formal implementation based on the legacy byte loops must stage the whole transfer and report the architectural base address.

### AME-MIG-003: overwriting matrix-multiply seed value

- Before: the legacy IDL initialized each overwriting dot-product partial result from an all-zero raw bit vector, while the normative instruction descriptions and programming model specified an ordinary mathematical matrix product.
- After: overwriting matrix multiplies seed each dot product with the accumulator datatype's semantic additive zero.  Accumulating forms continue to seed from the pre-instruction accumulator element.
- Evidence: `C = A x B`, `C = A^T^ x B`, `C = A x B^T^`, and `C = -(A x B)` are mathematical definitions whose sum identity is semantic zero; the raw-bit initialization is the sole conflicting IDL implementation detail.  The distinction is observable only for a custom datatype whose additive-zero encoding is not all-zero bits.
- Architectural impact: standard integer and IEEE floating-point datatypes are unaffected.  A custom accumulator datatype with a nonzero additive-zero encoding must follow its numeric zero rather than the legacy raw initializer.

### AME-MIG-004: row zip/unzip wide-tuple ambiguity

- Before: the legacy prose and IDL name literal consecutive bases (`base`, `base+1`) for the two squares, while the same IDL permits operation support to be queried for a wide datatype whose square occupies a multi-register aligned group.  The derived `base+1` then overlaps the first wide group and cannot itself satisfy that group's alignment.
- After: each of the two operands is both a source and a destination: the instructions consume the sole square from each of `ms1` and `ms2` and write the two result squares back into `ms1` and `ms2`, so every square keeps its own operand alignment and no derived consecutive base remains.  `ms1` and `ms2` must name distinct M registers; an equal pair raises an `Illegal Instruction` exception before any register is read or written, because an aliased pair would assign every element position twice.  The datatypes of `ms1` and `ms2` must match; a mismatch reports `amestatus.UN` rather than an exception.  Packed datatypes are no longer supported by the zip/unzip family; every Permutation instruction requires a datatype no smaller than `AME_UNIT_DATATYPE_SIZE`.
- Evidence: this retains the element loop of the legacy instruction definitions for every supported case and resolves the internally contradictory wide case by making each operand its own aligned square instead of deriving a second base.
- Architectural impact: an implementation may advertise zip/unzip support for wide datatypes; each operand then spans its own multi-register aligned group.  Packed datatypes, previously mapped to slot 0 of the literal registers, now raise the unsupported-operation contract instead.

### AME-MIG-005: transposed matrix formation when `N_sq > 1`

- Before: the programming model forms aggregate rectangular A and B operands for `N_sq > 1`, but the shorthand `A^T^ x B` and `A x B^T^` is dimensionally undefined for those rectangles.
- After: transpose-A and transpose-B apply within each paired `N x N` logical square and sum the square products: `sum_s(A_s^T^ x B_s)` or `sum_s(A_s x B_s^T^)`.
- Evidence: the per-square definition agrees with the instruction behavior for `N_sq = 1`, preserves the `N_sq * N` product terms per output element, and yields the required `N x N` accumulator for every `N_sq`.
- Architectural impact: packed/mixed-width transposed matrix operations now have one defined association of source coordinates.  Implementations using a different ad hoc interpretation must adopt the per-square mapping.

### AME-MIG-006: fixed scalar-exponent datatype selection

- Before: two instruction descriptions referenced `AME_MAX_INT_DTYPE`, but the parameter was absent from the parameter chapter.  “Maximum supported integer datatype” was undefined when no integer datatype was supported and was non-unique when several encodings shared the greatest width.
- After: when integer datatypes are supported, `AME_MAX_INT_DTYPE` selects a greatest-width supported integer encoding and ties are implementation-documented.  With no supported integer datatype, the parameter is absent and all `mldexp.ew.x` and `mldexpacc.ew.x` tuples are unsupported.  X-register bits are zero-extended or low-bit truncated to the selected width before interpretation.
- Evidence: this makes the instruction text instantiable without imposing a new minimum datatype set, preserves the legacy bit-vector widening/truncation behavior, and leaves the implementation's operation-support freedom intact.
- Architectural impact: float-only implementations deterministically report `amestatus.UN` for these two forms; implementations with same-width integer encodings must document which encoding supplies signedness and other datatype properties.

### AME-MIG-007: opaque memory transfers do not inspect `Md`

- Before: the baseline programming-model exception paragraph described unsupported-datatype reporting for every AME load and store, while the `mls` and `mss` IDL transferred one raw physical M register without reading `Md`.
- After: only interoperability and strided typed transfers perform datatype-support checks.  Opaque `mls` and `mss` ignore `Md` and transfer the selected physical register bit-for-bit.
- Evidence: the opaque instruction descriptions define implementation-format save/restore, and the legacy operations directly call the raw memory helper on `M[md]` or `M[ms1]` without a datatype lookup or support predicate.
- Architectural impact: an uninitialized or unsupported `Md` value cannot cause `amestatus.UN` for opaque save/restore; index, alignment, and ordinary memory faults still apply.

## Legacy-check disposition

| Legacy assertion family | Replacement |
|---|---|
| WaveDrom/decode-variable equality | Mnemonic operand fields must equal WaveDrom operand fields; exact baseline identity is checked. |
| Scalar-data helper selection | Family contract lint requires data-scalar pages to reference `ame-common-datatype-support`; fixed-control scalar pages must not claim datatype conversion. |
| Fold seed and association | Reduction pages must reference `ame-common-structural`, which defines seed and ordered/unordered behavior. |
| Numeric matrix accumulation | Matrix pages must reference `ame-common-matmul`, which prohibits raw bit-vector accumulation. |
| Wide conversion path | Conversion pages must reference register-group formation and conversion contracts. |
| Snapshot/staged writeback | Destination-as-source, scatter, and overlap pages must reference `ame-common-register-groups`. |
| IDL local declarations and bit slices | Retired with IDL syntax; no prose equivalent is required. |

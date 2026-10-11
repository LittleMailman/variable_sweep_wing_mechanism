# MATLAB 机构设计与分析代码

本目录收录可变后掠翼机构设计和分析所用的 MATLAB 计算程序，包含杆长综合、压力角与传动角、双侧机构运动学、摇杆角度，以及平面受力与动力学分析。程序统一存放于 `code/`。

> **状态说明**：7 个分析入口已在 MATLAB 中运行并生成输出；目前属于**运行和可视化初步验证**，不是结构性能、动力学模型或 SolidWorks 装配关系的最终工程验证。

## 目录和入口

所有 `.m` 文件放在同一级目录，直接将其添加为 MATLAB 当前工作文件夹即可运行。MATLAB 版本、第三方工具箱需求尚未做跨版本测试；从现有源码看主要使用基础数值计算及绘图函数。

| 运行入口 | 作用 | 直接调用的辅助函数 | 对应结果 |
|---|---|---|---|
| `design_link_lengths.m` | 三组设计角度下的连杆尺寸综合 | `solve_link_length_ratios.m` | [连杆尺寸结果](../results/images/link_length_design.md) |
| `plot_pressure_transmission_angles.m` | 压力角与传动角随曲柄角变化 | `compute_pressure_transmission_angles.m` | [压力角与传动角](../results/images/pressure_transmission_angles.jpg) |
| `plot_linkage_kinematics.m` | 双侧角位移、角速度、角加速度 | `solve_side_a_kinematics.m`, `solve_side_b_kinematics.m` | [运动学曲线](../results/images/linkage_kinematics.jpg) |
| `plot_relative_linkage_kinematics.m` | 双侧相对角位移、角速度、角加速度 | `solve_side_a_kinematics.m`, `solve_side_b_kinematics.m` | [相对运动曲线](../results/images/relative_linkage_kinematics.jpg) |
| `plot_rocker_angle_response.m` | 两侧摇杆角度响应 | `compute_dual_rocker_angles.m` | [双侧摇杆角度](../results/images/dual_rocker_angles.jpg) |
| `plot_joint_reaction.m` | 简化外载荷下的反力与曲柄力矩计算曲线 | `compute_joint_reaction.m` | [运动反力](../results/images/joint_reaction.jpg) |
| `analyze_linkage_joint_forces.m` | 9×9 平面平衡方程下的关节反力与驱动力矩 | 无外部 `.m` 依赖 | [动力学与关节反力](../results/images/linkage_joint_forces.jpg) |

**共计 13 个 MATLAB 文件：7 个入口脚本、6 个辅助函数。**不建议分开放置而不配置 MATLAB 搜索路径。

## 运行方式

MATLAB 中打开项目内的 `code` 目录，并依次执行（每个脚本可以独立运行）：

```matlab
clear; clc; close all;
design_link_lengths

clear; clc; close all;
plot_pressure_transmission_angles

clear; clc; close all;
plot_linkage_kinematics

clear; clc; close all;
plot_relative_linkage_kinematics

clear; clc; close all;
plot_rocker_angle_response

clear; clc; close all;
plot_joint_reaction

clear; clc; close all;
analyze_linkage_joint_forces
```

提示：部分绘图脚本末尾含 `hold on`，应在不同程序之间执行 `close all`，避免叠图。MATLAB 当前工作目录须包含对应的辅助函数文件。


## 示例参数与单位

| 项目 | 源码采用值 | 备注 |
|---|---|---|
| 曲柄长度 | 100 mm | 尺寸综合的基准值 |
| 连杆 / 摇杆 | 约 385.65 / 230.19 mm | 来自尺寸综合案例 |
| 机架长度 | 457.76 mm 或 457.79 mm | 不同脚本存在 **0.03 mm 不一致**，待与 CAD 核对 |
| 双侧曲柄偏置 | 106° | 几何定义、正负方向待与 CAD 装配核对 |
| 运动学主脚本输入角速度 | 100 rad/s | `plot_linkage_kinematics`、相对运动脚本 |
| 动力学主脚本输入角速度 | 10 rad/s | `analyze_linkage_joint_forces` |
| 动力学质量、惯量、负载 | 当前计算输入 | 尚非实物质量属性/设计载荷 |

**受力模型不是同一个已校准的物理试验**：`plot_joint_reaction.m` 使用的是无量纲杆长 `x1 = 1`、`r = 0.2`、`Fz = 100 N` 的示例工况；右图将 `FRX*x1` 标为 N·m，但 `x1` 并未以米为单位定义，**不能作为真实驱动力矩**。另一方面，`analyze_linkage_joint_forces.m` 已采用 m、kg、s、N 和 N·m，但质量、惯量与 100 N·m 工作阻力矩尚未核验。

## 已知待核对问题

1. `plot_linkage_kinematics.m` 和 `plot_relative_linkage_kinematics.m` 中 `theta01 < 106` 把**弧度角**与数值 `106` 直接比较。现有扫描下它会始终走同一个分支；保持原运行结果以便复现，但必须在修订运动学关系前核对相位和方向。
2. `compute_dual_rocker_angles.m` 第一侧二次方程已采用单层判别式平方根；其角度参考方向、所选根分支和 60° 偏置仍待与机械装配几何交叉验证。
3. 两组力学分析的载荷假设不同，结果不能直接相互比较。
4. 当前程序尚未使用 SolidWorks 导出的真实质量、转动惯量、质心及传动效率数据。
5. 图表中某些角度和力矩单位采用当前代码中的单位标注，**图像属于当前代码的示例工况输出，不作为最终工程性能指标**。

更详细的输出和验证边界参见 [`results/README.md`](../results/images/README.md) 和 [`results/VALIDATION_NOTES.md`](../results/images/VALIDATION_NOTES.md)。

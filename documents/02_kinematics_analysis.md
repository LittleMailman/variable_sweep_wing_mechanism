# 02 可变后掠翼机构运动学分析报告

## 1. 尺度综合及输入参数

为分析机构运动，将单侧机构简化为平面四杆机构，以曲柄长度为尺度基准进行杆长综合。当前 MATLAB 尺寸综合程序输出的参数如下：

| 变量 | 对应构件 | 尺寸 |
| --- | --- | ---: |
| $`x_1`$ | 曲柄 | 100.00 mm |
| $`x_2`$ | 连杆 | 385.65 mm |
| $`x_3`$ | 摇杆 | 230.19 mm |
| $`x_4`$ | 机架 | 457.76 mm |

程序入口：[`design_link_lengths.m`](../code/design_link_lengths.m)，内部调用 [`solve_link_length_ratios.m`](../code/solve_link_length_ratios.m)。尺寸综合采用三组曲柄与摇杆角度样本，当前程序中的偏置参数为 $`\phi_0=72^\circ`$；另有参数记录为 $`67^\circ`$。两者不一致，需要结合 CAD 构型和角度定义统一。

当前运动学程序的机架值另有 **457.79 mm**，与尺寸综合的 457.76 mm 不完全相同。该差异暂作为待核对参数保留，尚不能据此确定 CAD 模型的统一机架尺寸。

按这组示例杆长，最短杆加最长杆为 557.76 mm，其余两杆之和为 615.84 mm，满足 Grashof 长度条件；具体运动类型还需考虑固定杆和机构装配构型。

## 2. 四杆运动学模型

设曲柄、连杆和摇杆相对统一参考轴的角度为 $`\theta_1`$、$`\theta_2`$、$`\theta_3`$。单侧平面四杆闭环关系可写为：

```math
\begin{aligned}
x_1\cos\theta_1+x_2\cos\theta_2 &=x_4+x_3\cos\theta_3,\\
x_1\sin\theta_1+x_2\sin\theta_2 &=x_3\sin\theta_3.
\end{aligned}
```

对闭环方程求时间导数，得到从动杆角速度的线性方程：

```math
\begin{bmatrix}
-x_2\sin\theta_2 & x_3\sin\theta_3\\
x_2\cos\theta_2 & -x_3\cos\theta_3
\end{bmatrix}
\begin{bmatrix}\omega_2\\\omega_3\end{bmatrix}
=
\omega_1\begin{bmatrix}x_1\sin\theta_1\\-x_1\cos\theta_1\end{bmatrix}.
```

再次求时间导数可求角加速度。实际 MATLAB 计算函数为 [`solve_side_a_kinematics.m`](../code/solve_side_a_kinematics.m) 与 [`solve_side_b_kinematics.m`](../code/solve_side_b_kinematics.m)。两侧模型使用类似计算框架，但需要单独规定角度方向、对称映射及曲柄相位。

## 3. 压力角与传动角

连接固定铰点与曲柄末端得到辅助对角线，其长度平方为：

```math
d^2=x_1^2+x_4^2-2x_1x_4\cos\theta_1.
```

按当前 MATLAB 程序的几何约定，首先使用余弦定理计算杆件夹角 $`\alpha_3`$，再取锐角传动角 $`\gamma=\min(\alpha_3,\pi-\alpha_3)`$，压力角为 $`\alpha=\pi/2-\gamma`$。

![压力角与传动角计算曲线](../results/images/pressure_transmission_angles.jpg)

曲线读图显示最小传动角约 **52°**、最大压力角约 **38°**；它们是当前示例几何参数下的数值结果，尚未考虑实际负载和加工误差。

程序：[`plot_pressure_transmission_angles.m`](../code/plot_pressure_transmission_angles.m)。

## 4. 双侧机构运动与相对运动

在当前 MATLAB 示例中，第一曲柄转角按 $`0^\circ`$ 至 $`360^\circ`$ 扫描，曲柄输入角速度设为 **100 rad/s**，绘制两侧杆件角位移、角速度和角加速度：

![双侧机构运动学计算](../results/images/linkage_kinematics.jpg)

程序：[`plot_linkage_kinematics.m`](../code/plot_linkage_kinematics.m)。上述 100 rad/s 是**数学计算工况**，不是视频中蜗杆 200 RPM 的实际运动速度。

相对角位移与角速度可通过对应绝对运动量相减，例如：

```math
\theta_{13}=\theta_1-\theta_3,\qquad
\omega_{13}=\omega_1-\omega_3.
```

![机构相对运动计算](../results/images/relative_linkage_kinematics.jpg)

程序：[`plot_relative_linkage_kinematics.m`](../code/plot_relative_linkage_kinematics.m)。由于曲柄可整周转动，部分相对角度存在一周累计变化，并不直接表示摇杆无法往复摆动。

## 5. 双侧摇杆响应与曲柄夹角

双侧曲柄分析采用过 **106°** 的相位设定；另有约 **94.24°** 的极限/死点几何构型，以及考虑实体布置后的 **103°** 配置。三个角度对应不同分析条件，不能直接互换，需在 CAD 构型和角度参考系统一后确定最终计算参数。

![双侧摇杆角度计算](../results/images/dual_rocker_angles.jpg)

对应入口：[`plot_rocker_angle_response.m`](../code/plot_rocker_angle_response.m)，调用 [`compute_dual_rocker_angles.m`](../code/compute_dual_rocker_angles.m)。摇杆角求解采用判别式的单层平方根；当前程序可生成曲线，但求解分支及角度零位仍须与机构装配体校验。

**注意：** 图中的摇杆角度不是未经转换就可使用的“机翼实际后掠角”。应先统一左右翼参考轴和镜像方向，再建立摇杆到翼根后掠角的映射。

## 6. 当前计算结果的验证边界

六组运动学相关分析已在 MATLAB 中生成相应曲线，完成了基本运行与连续性检查；目前还没有完成：

- 以 SolidWorks 运动研究导出翼根角度并与 MATLAB 同步比较；
- 检查全行程几何闭合、装配分支、构件碰撞和实际左右同步误差；
- 将示例运动学角速度换算到真实蜗杆驱动工况；
- 将 457.76/457.79 mm、103°/106°、$`\phi_0=67^\circ/72^\circ`$ 等差异统一到最终参数版本。

下一篇见：[03 动力学分析报告](03_dynamics_analysis.md)。

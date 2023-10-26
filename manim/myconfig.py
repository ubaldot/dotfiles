import manim as mn  # type: ignore
import numpy as np
import numpy.typing as npt
import random

# Latex Stuff
myTexTemplate = mn.TexTemplate()
# myTexTemplate.add_to_preamble(r"\usepackage{mathastext}")
# myTexTemplate.add_to_preamble(r"\MTfamily{augie}\Mathastext")

# Control Theory in Practice colors
ctip_grey_rgb = (122,122,122)
ctip_blue_rgb = (61,127,187)
ctip_grey = tuple(c/255 for c in ctip_grey_rgb)
ctip_blue = tuple(c/255 for c in ctip_blue_rgb)
# TODO: redefine complementary colors
COMPLEMENTARY = ["#1F5887", "#6EBEFF", "#4694D4", "#875912", "#D49C46"]
TRIAD = ["#1F5887", "#D45F5B", "#4694D4", "#CDD431", "#838726"]


mypath = "/users/ubaldot/Documents/YouTube/ControlTheoryInPractice/github_ctip/"
file = "ManimBG.png"
imageBG = (
    mn.ImageMobject(mypath + file)
    .stretch_to_fit_width(mn.config.frame_width)
    .stretch_to_fit_height(mn.config.frame_height)
)

berlin = "Berlin Sans FB"
berlin_demi = "Berlin Sans FB Demi"

# Handwritten style
def handwrite(mob, delta=0.1):
    handles = mob.get_anchors_and_handles()[1]
    for handle in handles:
        noise = [random.uniform(-delta, delta) for p in range(0, 2)]
        noise.append(0.0)  # z-coordinate is kept the same
        handle += noise


def LPF(signal, fs, fc):
    signal_filt = np.empty_like(signal)
    signal_filt[0] = signal[0]
    for ii, s in enumerate(signal[1:]):
        signal_filt[ii + 1] = (1 - fc / fs) * signal_filt[ii] + fc / fs * s
    return signal_filt


def get_xgrid(ax, delta=0.0, stroke_opacity=0.6, stroke_width=2, dash_length=0.1):
    """
    Return dashed grid associated to the x-axis of ax.

    grid = mn.get_xgrid(ax, delta, dash_length)

    """

    ymin, ymax, ystep = ax.get_y_axis().x_range
    if delta:
        ystep = delta

    xmin, xmax, xstep = ax.get_x_axis().x_range
    xgrid = mn.VGroup()
    # Lines from 0.0 to ymax (going positive)
    for y in np.arange(max(0.0, ymin) + ystep, ymax, ystep):
        p0 = ax.c2p(xmin, y)
        p1 = ax.c2p(xmax, y)
        line = mn.DashedLine(p0, p1, stroke_opacity=stroke_opacity, stroke_width=stroke_width, dash_length=dash_length)
        xgrid.add(line)
    # Lines from 0.0 ymin (going negative)
    for y in np.arange(min(0.0, ymax) - ystep, ymin, -ystep):
        p0 = ax.c2p(xmin, y)
        p1 = ax.c2p(xmax, y)
        line = mn.DashedLine(p0, p1, stroke_opacity=stroke_opacity, stroke_width=stroke_width, dash_length=dash_length)
        xgrid.add(line)
    return xgrid


def get_ygrid(ax, delta=0.0, stroke_opacity=0.6, stroke_width=2, dash_length=0.1):
    """
    Return dashed grid associated to the y-axis of ax.

    grid = mn.get_ygrid(ax, delta, dash_length)

    """

    xmin, xmax, xstep = ax.get_x_axis().x_range
    if delta:
        xstep = delta

    ymin, ymax, ystep = ax.get_y_axis().x_range

    ygrid = mn.VGroup()
    for x in np.arange(max(0.0, xmin) + xstep, xmax, xstep):
        p0 = ax.c2p(x, ymin)
        p1 = ax.c2p(x, ymax)
        line = mn.DashedLine(p0, p1, stroke_opacity=stroke_opacity, stroke_width=stroke_width, dash_length=dash_length)
        ygrid.add(line)
    for x in np.arange(min(0.0, xmax) - xstep, xmin, -xstep):
        p0 = ax.c2p(x, ymin)
        p1 = ax.c2p(x, ymax)
        line = mn.DashedLine(p0, p1, stroke_opacity=stroke_opacity, stroke_width=stroke_width, dash_length=dash_length)
        ygrid.add(line)
    return ygrid


def get_grid(
    ax,
    x_delta=0.0,
    y_delta=0.0,
    x_stroke_opacity=0.6,
    x_stroke_width=2,
    y_stroke_opacity=0.6,
    y_stroke_width=2,
    dash_length=0.1,
):
    """
    Return dashed grid associated to the passed Axes.

    grid = mn.get_grid(ax, x_range, y_range, dash_length)

    """
    return mn.VGroup(
        get_xgrid(ax, y_delta, x_stroke_opacity, x_stroke_width, dash_length),
        get_ygrid(ax, x_delta, y_stroke_opacity, y_stroke_width, dash_length),
    )


def get_axis_config(alpha: bool = False):
    """
    Return (axes_config, plot_stroke_width)

    ax_config, plot_stroke_width = get_axis_config(alpha)

    Alpha is meant to be used for overlays.
    """

    if alpha:
        plot_stroke_width = 8
        axis_config = {
            "include_numbers": False,
            "tick_size": 0.0,
            "tip_width": 0.1,
            "tip_height": 0.1,
            "font_size": 48,
            "stroke_width": 6,
        }
    else:
        plot_stroke_width = 3
        axis_config = {
            "include_numbers": True,
            "tip_shape": mn.StealthTip,
            "tick_size": 0.0,
            "tip_width": 0.1,
            "tip_height": 0.1,
            "font_size": 28,
        }
    return axis_config, plot_stroke_width


# Square continuous signals to avoid FOH.
def _square_data(times, signal, discontinuity_points, alpha=0.0):
    """
    Manim interpolates with FOH, i.e. "/".
    This function is used to get "_|" or "|_" instead of "/" between two consecutive "continuous" points.
    The discontinuity point is the "left" point.

    You can have either "|_" (alpha = 0) or "_|" (alpha = 1) or anything in the middle.
    The discontinuity points are indices and are found by other functions (zoh, lebesgue_sampling, etc).
    """
    if alpha < 0 or alpha > 1:
        raise ValueError("alpha must be in [0,1].")
    # We need to add two points: A = (tx,s0) and B = (tx,s1) where sampling_instant < tx < sampling_instant + Ts
    s = np.array([[signal[p], signal[p + 1]] for p in discontinuity_points])
    t = np.array(
        [
            [
                alpha * (times[p + 1] - times[p]) + times[p],
                alpha * (times[p + 1] - times[p]) + times[p],
            ]
            for p in discontinuity_points
        ]
    )

    signal = np.insert(signal, np.repeat(discontinuity_points + 1, s.shape[1]), s.ravel())
    times = np.insert(times, np.repeat(discontinuity_points + 1, t.shape[1]), t.ravel())

    return times, signal


def zoh(times: npt.ArrayLike, signal: npt.ArrayLike, Ts: float):
    """
    Flatten the values between two consecutive sampling points, thus getting a piece-wise continuous function.

    Example
    -------
    zoh_times, zoh_signal = zoh(times, signals, Ts=0.2, alpha = 0)
    graph = axes.plot_line_graph(zoh_times,zoh_signals)
    """
    zoh_signal = np.empty_like(signal)
    N = int(Ts / (times[1] - times[0]))
    for ii, val in enumerate(signal):
        if ii % N == 0:
            closest_value = val  # ZOH
            prev_val = val
        else:
            closest_value = prev_val
        zoh_signal[ii] = closest_value

    discontinuity_points = np.asarray(range(N - 1, len(times) - 1, N))
    return _square_data(times, zoh_signal, discontinuity_points, alpha=1.0)


def lebesgue_sampling(
    times: npt.ArrayLike,
    signal: npt.ArrayLike,
    bins: npt.ArrayLike,
    quantize=False,
):
    """
    Sample when signal is on the boundary of a bin, thus getting a piece-wise continuous function.
    If quantize =True, then the signal value is quantized wrt to the closest bin, i.e. the resulting piece-wise
    amplitude is signal is q(s(tk)) - to the closest bin - instead of s(tk).

    Example
    -------
    eb_times, eb_signal = lebesgue_sampling(times, signals, bins, alpha = 0.0)
    graph = axes.plot_line_graph(eb_times,eb_signals)
    """
    eb_signal = np.empty_like(signal)
    bins_no = np.digitize(signal, bins)

    sampling_points = np.nonzero(np.diff((bins_no)))[0]

    # Init
    if quantize:
        prev_val = min(bins, key=lambda x: np.abs(x - signal[0]))
    else:
        prev_val = signal[0]
    eb_signal[0] = prev_val

    for ii, _ in enumerate(signal[:-1]):
        if ii in sampling_points:
            if quantize:
                closest_value = min(bins, key=lambda x: np.abs(x - signal[ii + 1]))
            else:
                closest_value = signal[ii + 1]
            prev_val = closest_value
        else:
            closest_value = prev_val
        eb_signal[ii + 1] = closest_value
    return _square_data(times, eb_signal, sampling_points, alpha=1)


def quantize(times: npt.ArrayLike, signal: npt.ArrayLike, bins: npt.ArrayLike, alpha: float = 0.5):
    """
    Flatten the values of signal on the q_bins, thus getting a piece-wise continuous function.

    Example
    -------
    q_times, q_signal = quantize(times, signals, bins, alpha = 0.5)
    graph = axes.plot_line_graph(q_times,q_signals)
    """
    q_signal = np.empty_like(signal)
    for ii, val in enumerate(signal):
        closest_value = min(bins, key=lambda x: np.abs(x - val))
        q_signal[ii] = closest_value

    discontinuity_points = np.nonzero(np.diff(q_signal))[0]
    return _square_data(times, q_signal, discontinuity_points, alpha)


# # Exact quantization (to overcome Manim FOH internal interpolation)
# # Quantize values
# q_signal = np.empty_like(signal_filt)
# for ii, val in enumerate(signal_filt):
#     closest_value = min(q_bins, key=lambda x: np.abs(x - val))
#     q_signal[ii] = closest_value
# quantized_points = [ax.c2p(_x, _y) for _x, _y in zip(times, q_signal)]

# quantized_plot = mn.VMobject(color=mn.YELLOW)
# t_step = quantized_points[1][0] - quantized_points[0][0]
# for ii in range(len(quantized_points) - 1):
#     x0, y0, _ = quantized_points[ii]
#     x1, y1, _ = quantized_points[ii + 1]
#     l0 = mn.Line((x0, y0, 0), (x0 + t_step / 2, y0, 0))
#     l1 = mn.Line((x0 + t_step / 2, y0, 0), (x0 + t_step / 2, y1, 0))
#     l2 = mn.Line((x0 + t_step / 2, y1, 0), (x0 + t_step, y1, 0))
#     quantized_plot.append_vectorized_mobject(l0)
#     quantized_plot.append_vectorized_mobject(l1)
#     quantized_plot.append_vectorized_mobject(l2)

# Exact ZOH

# # (ZOH) Alternative
# steps = []
# for x, x_next, y in zip(x_values, x_values[1:], y_values):
#     steps.append([x, y, 0])
#     steps.append([x_next, y, 0])
# steps.append([x_values[-1], y_values[-1], 0])

# curve = mn.VMobject().set_points_as_corners(steps)
# curve2 = mn.VMobject().set_points_as_corners(points).set_color(mn.RED)
# self.add(curve, curve2, zoh_curve)


# Arrow tips
class ArrowStealthTip(mn.ArrowTip, mn.VMobject):
    def __init__(
        self, width=0.5, length=1, fraction=0.4, scale=1, stroke_width=mn.DEFAULT_STROKE_WIDTH, fill_opacity=1, **kwargs
    ):
        mn.VMobject.__init__(self, **kwargs)
        fraction = min(fraction, 0.999999)

        self.start_new_path(np.array([0, 1, 0]))

        self.add_line_to(  # straight line
            np.array((width / 2.0, 0.0, 0.0)),
        )
        self.add_quadratic_bezier_curve_to(  # curve to middle
            np.array((width / 4.0, fraction, 0.0)),
            np.array((0.0, fraction, 0.0)),
        )
        self.add_quadratic_bezier_curve_to(  # curve from middle
            np.array((-width / 4.0, fraction, 0.0)),
            np.array((-width / 2.0, 0.0, 0.0)),
        )
        self.add_line_to(np.array((0.0, 1, 0.0)))
        self.joint_type = mn.LineJointType.ROUND
        self.set_stroke(width=stroke_width)
        self.set_fill(opacity=fill_opacity)
        self.scale_to_fit_height(length * scale)


# Defaults
mn.Arrow.set_default(tip_shape=ArrowStealthTip)
mn.SingleStringMathTex.set_default(tex_template=myTexTemplate)
mn.MathTex.set_default(tex_template=myTexTemplate)
mn.Tex.set_default(tex_template=myTexTemplate)

# Default colors
# mn.MathTex.set_default(color=mn.BLACK)
# mn.Square.set_default(color=mn.BLACK)
# mn.Arrow.set_default(color=mn.BLACK)
# mn.Line.set_default(color=mn.BLACK)
# mn.DashedLine.set_default(color=mn.BLACK)
# mn.Dot.set_default(color=mn.BLACK)
# mn.NumberLine.set_default(color=mn.BLACK)


# vim: set textwidth=120:
def _square_data_old_old(times, signal, discontinuity_points):
    """
    OLD but GOOD!

    Manim interpolates with FOH. To have a piece-wise constant function we have to add an horizontal and a vertical
    segment between each discontinuity point, to get "_|" instead of "/" between two consecutive points.

    The discontinuity points are indices and are found by other functions (zoh, lebesgue_sampling, etc).
    """
    # Horizontal segments
    signal = np.insert(signal, discontinuity_points, signal[discontinuity_points])
    times = np.insert(times, discontinuity_points + 1, times[discontinuity_points + 1])
    # Vertical segments
    signal = np.insert(signal, discontinuity_points + 1, signal[discontinuity_points + 1])
    times = np.insert(times, discontinuity_points, times[discontinuity_points])

    return times, signal


def _square_data_old(times, signal, discontinuity_points, alpha=0.0):
    """
    Manim interpolates with FOH, i.e. "/".
    This function is used to get "_|" or "|_" instead of "/" between two consecutive points.

    You can have either "|_" (alpha = 0) or "_|" (alpha = 1)
    The discontinuity points are indices and are found by other functions (zoh, lebesgue_sampling, etc).
    """
    print(discontinuity_points)
    if alpha < 0 or alpha > 1:
        raise ValueError("alpha must be in [0,1].")

    for ii, p in enumerate(discontinuity_points):
        idx = p + ii * 2
        # np.insert add to the left, but we want to add to the right, that is why idx+1 in position
        signal = np.insert(signal, idx + 1, [signal[idx], signal[idx + 1]])

        delta_t = alpha * (times[idx + 1] - times[idx])
        times = np.insert(times, idx + 1, [times[idx] + delta_t, times[idx] + delta_t])

    return times, signal


def _square_data_OLD(times, signal, discontinuity_points, alpha=0.0):
    """
    Manim interpolates with FOH, i.e. "/".
    This function is used to get "_|" or "|_" instead of "/" between two consecutive "continuous" points.

    You can have either "|_" (alpha = 0) or "_|" (alpha = 1) or anything in the middle.
    The discontinuity points are indices and are found by other functions (zoh, lebesgue_sampling, etc).
    """
    if alpha < 0 or alpha > 1:
        raise ValueError("alpha must be in [0,1].")
    # We need to add two points: A = (tx,s0) and B = (tx,s1) where sampling_instant < tx < sampling_instant + Ts
    s = np.array([[signal[p], signal[p + 1]] for p in discontinuity_points])
    t = np.array(
        [
            [
                alpha * (times[p + 1] - times[p]) + times[p],
                alpha * (times[p + 1] - times[p]) + times[p],
            ]
            for p in discontinuity_points
        ]
    )

    # signal = np.insert(signal, discontinuity_points, s)
    # times = np.insert(times, discontinuity_points, t)
    for ii, p in enumerate(discontinuity_points):
        idx = p + ii * 2
        # np.insert add to the left, but we want to add to the right, that is why idx+1 in position
        signal = np.insert(signal, idx + 1, s[ii])

        # delta_t = alpha * (times[idx + 1] - times[idx])
        times = np.insert(times, idx + 1, t[ii])

    return times, signal

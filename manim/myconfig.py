import manim as mn  # type: ignore
import numpy as np
import random

# Latex Stuff
myTexTemplate = mn.TexTemplate()
# myTexTemplate.add_to_preamble(r"\usepackage{mathastext}")
# myTexTemplate.add_to_preamble(r"\MTfamily{augie}\Mathastext")

# Control Theory in Practice colors
COMPLEMENTARY = ["#1F5887", "#6EBEFF", "#4694D4", "#875912", "#D49C46"]
TRIAD = ["#1F5887", "#D45F5B", "#4694D4", "#CDD431", "#838726"]


mypath = "/users/ubaldot/Documents/YouTube/ControlTheoryInPractice/"
file = "ManimBG.png"
imageBG = (
    mn.ImageMobject(mypath + file)
    .stretch_to_fit_width(mn.config.frame_width)
    .stretch_to_fit_height(mn.config.frame_height)
)


# Common axis properties
axis_config = {
    "include_numbers": True,
    "tick_size": 0.0,
    "tip_width": 0.1,
    "tip_height": 0.1,
    "font_size": 24,
}


# Handwritten style
def handwrite(mob, delta=0.1):
    handles = mob.get_anchors_and_handles()[1]
    for handle in handles:
        noise = [random.uniform(-delta, delta) for p in range(0, 2)]
        noise.append(0.0)  # z-coordinate is kept the same
        handle += noise


# Arrow tips
class ArrowStealthTip(mn.ArrowTip, mn.VMobject):
    def __init__(
        self,
        width=0.5,
        length=1,
        fraction=0.4,
        scale=1,
        stroke_width=mn.DEFAULT_STROKE_WIDTH,
        fill_opacity=1,
        **kwargs
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

import manim as mn
import numpy as np


def search_shape_in_text(text: mn.VMobject, shape: mn.VMobject, index=0):
    """Receives two VMobjects resulting from rendering text (either by Tex, Text
    or MathTex) and looks for occurrences of the second in the first, but comparing
    the shapes and not the text itself.
    In essence, it goes through all the elements of text[0] grouped according to the
    number of elements of shape[0], and for each group it calculates a hash of
    both shapes and compares them.
    It returns a list with all the indices of text[0] where it was found. Each
    element of that list is a slice because the text may span more than one
    element of text[0].
    Example (changing the color of all x's):
       gx = MathTex(r'''
            g(x) = \begin{cases}
            x(2-x) &(|x-1| \leq 1) \\
            0 &(|x-1| > 1)
            \end{cases}''')
        self.add(gx)
        self.wait()
        self.play(*[
            Transform(gx[0][group], MathTex("a").move_to(gx[0][group]), path_arc=-PI)
            for group in search_shape_in_text(gx, MathTex("x"))
        ])
        self.wait()
    """

    def get_mobject_key(mobject: mn.Mobject) -> int:
        mobject.save_state()
        mobject.center()
        mobject.scale_to_fit_height(1)
        result = hash(
            np.array2string(
                mobject.points,
                precision=3,
                separator=", ",
                suppress_small=True,
            )
        )
        mobject.restore()
        return result

    results = []
    l = len(shape.submobjects[0])
    shape_aux = mn.VMobject()
    shape_aux.points = np.concatenate(
        [p.points for p in shape.submobjects[0]]
    )
    for i in range(len(text.submobjects[index])):
        subtext = mn.VMobject()
        subtext.points = np.concatenate(
            [p.points for p in text.submobjects[index][i : i + l]]
        )
        if get_mobject_key(subtext) == get_mobject_key(shape_aux):
            results.append(slice(i, i + l))
    return results


def search_shapes_in_text(
    text: mn.VMobject, shapes: list[mn.VMobject], index=0
):
    """Like the previous one, but receives a list of possible sub-texts to search for.
    Example (replaces all x's, both normal and small ones,
    which have a different shape):
        gx = MathTex(r'''
            \sum_{x=0}^\infty \frac{1}{x!} = e^x
            ''').scale(3)
        self.add(gx)
        self.wait()
        self.play(*[
            gx[0][group].animate.set_color(YELLOW)
            for group in search_shapes_in_text(gx, [MathTex("x"), MathTex("^x")])
        ])
        self.wait()
    """
    results = []
    for shape in shapes:
        results += search_shape_in_text(text, shape, index)
    return results


def group_shapes_in_text(
    text: mn.VMobject, shapes: mn.VMobject | list[mn.VMobject], index=0
):
    """
    This functions receives a text in which it has to search a given shape (or list of shapes)
    It returns a VGroup with the shapes found in the text
    It is a usability improvement with respect to search_shape_in_text, because it directly returns
    a group of VMobjects instead of index slices. It also accepts a list or a single shape.
    Example of use (replaces all x's, both normal and small ones,
    which have a different shape):
        gx = MathTex(r'''
            \sum_{x=0}^\infty \frac{1}{x!} = e^x
            ''').scale(3)
        self.add(gx)
        self.wait()
        results = group_shapes_in_text(gx, [MathTex("x"), MathTex("^x")])
        self.play(results.animate.set_color(YELLOW))
        self.wait()
    """
    if isinstance(shapes, mn.VMobject):
        shapes = [shapes]
    results = search_shapes_in_text(text, shapes, index)
    return mn.VGroup(*[text[index][s] for s in results])

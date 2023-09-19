from scipy import ndimage
import manim as mn
import imageio.v3 as iio
import sys


sys.path.append("/users/ubaldot/.manim")
import myconfig as mycfg  # type:ignore


class PixelImage(mn.Scene):
    def setup(self):
        mypath = "/users/ubaldot/Documents/YouTube/ControlTheoryInPractice/"
        file = "ManimBG.png"
        image = (
            mn.ImageMobject(mypath + file)
            .stretch_to_fit_width(mn.config.frame_width)
            .stretch_to_fit_height(mn.config.frame_height)
        )

        self.add(image)

    def construct(self):
        self.next_section("Empty grid", skip_animations=False)
        N_pixels = 30
        rows, cols = (
            N_pixels,
            N_pixels,
        )  # Number of rows and columns in the grid

        # Filled grid
        # im = iio.imread("IO.jpeg")
        im = iio.imread("Io2.jpeg")
        print(im.shape)
        im_resized = ndimage.zoom(im, (N_pixels / im.shape[0], N_pixels / im.shape[1], 1), order=3)
        print(im.shape)
        filled_grid_original = mn.VGroup(
            *[
                mn.Square(
                    # 0.2,
                    6 / N_pixels,
                    stroke_width=0.0,
                    fill_opacity=1,
                    fill_color=mn.rgb_to_color(
                        (
                            im_resized[x, y, 0] / 255,
                            im_resized[x, y, 1] / 255,
                            im_resized[x, y, 2] / 255,
                        )
                    ),
                )
                for x in range(cols)
                for y in range(rows)
            ]
        ).arrange_in_grid(rows, cols, buff=0.0)
        filled_grid = filled_grid_original.copy()

        empty_grid = (
            mn.VGroup(*[mn.Square(6 / N_pixels, stroke_width=0.4) for x in range(cols) for y in range(rows)])
            .move_to(filled_grid)
            .arrange_in_grid(rows, cols, buff=0.0)
        )

        self.play(mn.Create(filled_grid))
        self.wait()
        self.play(mn.Transform(filled_grid, empty_grid))
        self.wait()

        self.play(filled_grid.animate.to_edge(mn.LEFT))
        self.wait(0.5)

        self.next_section("Highlight cells", skip_animations=False)

        independent_seq_txt = mn.Text("Independent sequence", font_size=42).to_corner(mn.UR, buff=1)
        pixel_position_txt = (
            mn.Text("pixel position = ", font_size=32).next_to(independent_seq_txt, mn.DOWN, aligned_edge=mn.LEFT)
            # .shift(0.2 * mn.RIGHT)
        )
        self.play(mn.Write(independent_seq_txt), mn.Write(pixel_position_txt))
        self.wait()

        # coords = [(random.randint(0, N_pixels), random.randint(0, N_pixels) ) for _ in range(6)]
        coords = [(0, ii) for ii in range(8)]
        for coord in coords:
            ii, jj = coord

            # On the grid
            ij_val_grid_txt = mn.Text(f"({ii}, {jj})", font_size=24, slant=mn.ITALIC).next_to(
                filled_grid[cols * ii + jj], mn.UP, buff=0.1
            )

            # Nearby "pixel position = "
            ij_val_txt = mn.Text(
                f" ({ii},  {jj})",
                font_size=32,
                slant=mn.ITALIC,
            ).next_to(pixel_position_txt, mn.RIGHT)

            self.add(ij_val_txt)
            self.add(ij_val_grid_txt)
            filled_grid[cols * ii + jj].become(filled_grid[cols * ii + jj].set_stroke(width=3.0))
            self.wait(0.8)
            filled_grid[cols * ii + jj].become(filled_grid[cols * ii + jj].set_stroke(width=0.4))
            self.remove(ij_val_txt, ij_val_grid_txt)

        self.next_section("Transform in picture", skip_animations=False)

        dependent_seq_txt = mn.Text("Dependent sequence", font_size=42).next_to(
            pixel_position_txt, mn.DOWN, aligned_edge=mn.LEFT, buff=1.2
        )

        RGB_values_txt = mn.Text("RGB Values", font_size=28).next_to(dependent_seq_txt, mn.DOWN, aligned_edge=mn.LEFT)

        # filled_grid_original = filled_grid_original.align_to(filled_grid)
        self.play(
            mn.Transform(filled_grid, filled_grid_original.to_edge(mn.LEFT)),
            mn.Write(dependent_seq_txt),
            mn.Write(RGB_values_txt),
        )
        self.wait(0.5)

        # coords = [(random.randint(0, N_pixels), random.randint(0, N_pixels) ) for _ in range(10)]
        for coord in coords:
            ii, jj = coord

            pixel_zoomed = (
                filled_grid[cols * ii + jj]
                .copy()
                .scale(6)
                .set_stroke(width=3)
                .next_to(RGB_values_txt, mn.DOWN, buff=0.6, aligned_edge=mn.LEFT)
                # .stretch_to_fit_width(5, about_edge=mn.LEFT)
            )

            R, G, B = mn.color_to_int_rgb(pixel_zoomed.get_color())
            RGB_values = (
                mn.VGroup(
                    mn.VGroup(
                        mn.Text(f"{R}", color=mn.PURE_RED, font_size=32), mn.Text("R", color=mn.PURE_RED, font_size=32)
                    ).arrange(mn.UP),
                    mn.VGroup(
                        mn.Text(f"{G}", color=mn.PURE_GREEN, font_size=32),
                        mn.Text("G", color=mn.PURE_GREEN, font_size=32),
                    ).arrange(mn.UP),
                    mn.VGroup(
                        mn.Text(f"{B}", color=mn.PURE_BLUE, font_size=32),
                        mn.Text("B", color=mn.PURE_BLUE, font_size=32),
                    ).arrange(mn.UP),
                )
                .arrange(mn.RIGHT, buff=0.1)
                .next_to(pixel_zoomed, mn.RIGHT)
            )

            # Pixel position
            ij_val_txt = mn.Text(
                f"({ii}, {jj})",
                font_size=32,
            ).next_to(pixel_position_txt, mn.RIGHT)

            ij_val_grid_txt = mn.Text(f"({ii},  {jj})", font_size=24, slant=mn.ITALIC).next_to(
                filled_grid[cols * ii + jj], mn.UP, buff=0.1
            )

            filled_grid[cols * ii + jj].become(filled_grid[cols * ii + jj].set_stroke(width=3.0))
            self.add(RGB_values_txt, RGB_values, ij_val_grid_txt)
            self.add(pixel_zoomed, ij_val_txt, ij_val_grid_txt)
            self.wait()

            filled_grid[cols * ii + jj].become(filled_grid[cols * ii + jj].set_stroke(width=0.4))
            self.remove(
                RGB_values,
                RGB_values_txt,
                ij_val_txt,
                ij_val_grid_txt,
                pixel_zoomed,
            )

        self.add(
            RGB_values,
            RGB_values_txt,
            ij_val_txt,
            ij_val_grid_txt,
            pixel_zoomed,
        )
        self.play(mn.Circumscribe(mn.VGroup(pixel_position_txt, ij_val_txt)))
        self.wait()
        self.play(mn.Circumscribe(RGB_values))

        self.next_section("TESTS", skip_animations=True)

        ii = 10
        jj = 251
        kk = 99
        T = mn.Text(f"({ii}, {jj}, {kk})")


        # self.add(T)
        # self.wait()
        # self.play(mn.FadeOut(self.mobjects))
        # self.wait(0.2)


# vim: set textwidth=120:

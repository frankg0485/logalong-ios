//
//  LTheme.swift
//  LogAlong
//
//  Created by Michael Gao on 12/22/17.
//  Copyright © 2017 Swoag Technology. All rights reserved.
//

import UIKit

class LTheme {
    class Color {
        static let input_bgd_color = UIColor(hex: 0xe4e6e8)
        static let base_menu_color = UIColor(hex: 0xa4a6a8)
        static let base_bgd_color = UIColor(hex: 0xd4d6d8)
        static let base_fgd_color = UIColor(hex: 0xdee2e6)
        static let base_bgd_separator_color = UIColor(hex: 0xc4c6c8)
        static let base_text_color = UIColor(hex: 0x303030)
        static let base_white_text_color = UIColor(hex: 0xf0f0f0)
        static let base_black_text_color = UIColor(hex: 0x202020)
        static let gray_text_color = UIColor(hex: 0x505050)
        static let light_gray_text_color = UIColor(hex: 0x606060)
        static let dark_gray_text_color = UIColor(hex: 0x808080)
        static let red_text_color = UIColor(hex: 0x6d5246)
        static let header_color = UIColor(hex: 0x304050)
        static let tab_text_color = UIColor(hex: 0xdddddd)
        static let header_text_color = UIColor(hex: 0xc0c0c0)
        static let footer_text_color = UIColor(hex: 0xf0f0f0)
        static let footer_color = UIColor(hex: 0x405060)
        static let warn_text_color = UIColor(hex: 0xffff40)
        static let base_red = UIColor(hex: 0xbb4238)
        static let base_green = UIColor(hex: 0x42bb38)
        static let base_light_green = UIColor(hex: 0xc0d8c0)
        static let base_blue = UIColor(hex: 0x4238bb)
        static let base_blue_color = UIColor(hex: 0x2487ab)
        static let base_orange = UIColor(hex: 0xbcb586)
        static let dollar_amount_picker_bg_color = UIColor(hex: 0x80000000)
        static let dialog_bg_color = UIColor(hex: 0x90000000)
        static let dialog_border_color = UIColor(hex: 0x848688)
        static let released_base_btn_background = UIColor(hex: 0x42bb38)
        static let pressed_base_btn_background = UIColor(hex: 0x52cb48)
        static let released_quickie_btn_background = UIColor(hex: 0xb4cdcd)
        static let pressed_quickie_btn_background = UIColor(hex: 0xe0eeee)
        static let released_btn_background = UIColor(hex: 0xbebec4)
        static let pressed_btn_background = UIColor(hex: 0x9e9ea4)
        static let released_emoji_btn_background = UIColor(hex: 0xd4d6d8)
        static let pressed_emoji_btn_background = UIColor(hex: 0xc4c6c8)
        static let released_emoji_backspace_btn_background = UIColor(hex: 0xe4e6e8)
        static let pressed_emoji_backspace_btn_background = UIColor(hex: 0xc4c6c8)
        static let released_login_btn_background = UIColor(hex: 0x42bb38)
        static let pressed_login_btn_background = UIColor(hex: 0x52cb48)
        static let released_alt_login_btn_background = UIColor(hex: 0x708088)
        static let pressed_alt_login_btn_background = UIColor(hex: 0x879f9f)
        static let pressed_dialog_btn_background = UIColor(hex: 0x979f9f)
        static let released_dialog_btn_background = UIColor(hex: 0xa4a6a8)
        static let topbar_bgd_color = UIColor(hex: 0x585c60)
        static let balance_header_bgd_color = UIColor(hex: 0xe4e6e8)
        static let row_released_color = UIColor(hex: 0xced0d2)
        static let top_bar_background = UIColor(hex: 0x585c60)
    }

    class Dimension {
        static let amount_picker_width: CGFloat = 360
        static let amount_picker_height: CGFloat = 320

        static let table_view_cell_height = 44
        static let bar_button_width: CGFloat = 25
        static let bar_button_height: CGFloat = 25
        static let bar_button_space: CGFloat = 5

        static let popover_width: CGFloat = 320
        static let popover_height: CGFloat = 320
        static let popover_height_small: CGFloat = 200
        static let tab_bar_icon_width: CGFloat = 32
        static let tab_bar_icon_height: CGFloat = 32
        static let balance_header_font_size: CGFloat = 14
        static let balance_header_right_margin: CGFloat = 16
        static let balance_header_left_margin: CGFloat = 16

        static let pie_chart_legend_offset: CGFloat = 10
    }
}

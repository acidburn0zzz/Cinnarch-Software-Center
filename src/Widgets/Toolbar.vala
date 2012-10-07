//
//  Copyright © 2012 Stephen Smally
//      This program is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 2 of the License, or
//      (at your option) any later version.
//      
//      This program is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//      GNU General Public License for more details.
//      
//      You should have received a copy of the GNU General Public License
//      along with this program; if not, write to the Free Software
//      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//      MA 02110-1301, USA.
//      

using Gtk;
using Granite.Widgets;

namespace Lsc.Widgets {
    public class MainToolbar : Toolbar {
        // Widgets
        private ToolItem tool;
        public EventBox back;
        public Image icon;
        public Button label;
        public SearchBar searchbar;
        
        public void update_label (Notebook nb, Widget pg, uint page_n) {
            PageType page_t = (PageType) page_n;
            switch (page_t) {
                case PageType.HOMEPAGE:
                    label.label = page_t.to_string();
                    icon.set_from_stock (Stock.HOME, IconSize.MENU);
                    break;
                case PageType.APPSVIEW:
                    label.label = last_category.name;
                    icon.set_from_icon_name (last_category.icon, IconSize.MENU);
                    break;
                case PageType.APPSINFO:
                    label.label = last_app.name;
                    icon.set_from_icon_name (last_app.icon, IconSize.MENU);
                    break;
            }
        }
        
        private void insert_with_tool (Widget widget, int pos) {
            tool = new ToolItem();
            tool.add(widget);
            insert(tool, pos);
        }
        
        public MainToolbar () {
            get_style_context().add_class("primary-toolbar");
            
            toolbar_style = ToolbarStyle.BOTH_HORIZ;
            show_arrow = false;
            
            Box button_b = new Box(Orientation.HORIZONTAL, 0);
            
            Image back_image = new Image.from_stock (Stock.GO_BACK, (IconSize) icon_size);
            back_image.margin = 5;
            back = new EventBox ();
            back.visible_window = false;
            back.add (back_image);
            icon = new Image ();
            label = new Button.with_label(PageType.HOMEPAGE.to_string());
            label.image = icon;
            label.image_position = PositionType.LEFT;
            label.can_focus = false;
            label.valign = Align.CENTER;
            label.vexpand = false;
            back.valign = Align.CENTER;
            back.vexpand = false;
            
            insert_with_tool (back, -1);
            button_b.pack_start(label, false, false, 0);
            insert_with_tool(button_b, -1);
            
            ToolItem space_item = new ToolItem();
            space_item.set_expand(true);
            insert(space_item, -1);
            
            searchbar = new SearchBar("Search apps...");
            searchbar.text_changed_pause.connect((text) => {stdout.printf("%s\n", text); });
            searchbar.margin = 5;
            insert_with_tool(searchbar, -1);
        }
    }
}


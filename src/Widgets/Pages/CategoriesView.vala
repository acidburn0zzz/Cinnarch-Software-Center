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

namespace Lsc.Widgets {   
    public class CategoryButton : EventBox {
        private AppStore.Category desc;
        public signal void category_clicked (AppStore.Category cat);
        
        private bool emit_clicked (Widget box, Gdk.EventButton button) {
            category_clicked (desc);
            return true;
        }
        
        public CategoryButton (AppStore.Category desc, bool fill = false) {
            this.desc = desc;
            
            sensitive = ! fill;
            visible_window = false;
            
            if (desc.icon != "" && ! fill) {
                Box container = new Box(Orientation.HORIZONTAL, 6);
                //container.border_width = 5;
                Box label_box = new Box(Orientation.VERTICAL, 0);
                label_box.valign = Align.CENTER;
                Image image_widget = new Image.from_icon_name(desc.icon, IconSize.DIALOG);
                image_widget.set_size_request (48, 48);
                
                Label title = new Label("%s".printf (desc.name));
                title.ellipsize = Pango.EllipsizeMode.END;
                title.halign = Align.START;
                title.valign = Align.END;
                
                tooltip_text = desc.summary;
                
                Label description = new Label("<i>%d elements</i>".printf (desc.records));
                description.ellipsize = Pango.EllipsizeMode.END;
                description.halign = Align.START;
                description.valign = Align.START;
                description.use_markup = true;
                description.sensitive = false;
                
                label_box.pack_start(title, false, false, 0);
                label_box.pack_start(description, false, false, 0);
                
                container.pack_start(image_widget, false, false, 0);
                container.pack_start(label_box, false, false, 0);
                add(container);
                
                button_press_event.connect(emit_clicked);
            }
        }
    }
    
    public class CategoriesView : GridView {
        public signal void category_choosed (AppStore.Category cat);
        
        // Vars
        private Box box_child;
        private CategoryButton button_child;
        public int columns { get; set; }
        private int actual_col;
        private new List<AppStore.Category> children = null;
        
        public void add_category (AppStore.Category cat) {
            children.append(cat);
        }
        
        public void reconfigure_grid () {
            foreach (Widget widget in container.get_children()) {
                container.remove(widget);
            }
            box_child = null;
            actual_col = columns;
            
            foreach (AppStore.Category button_desc in children) {
                if (actual_col == columns) {
                    box_child = new Box(Orientation.HORIZONTAL, 6);
                    box_child.homogeneous = true;
                    box_child.show();
                    grid_pack_start(box_child, true, true, 0);
                    actual_col = 0;
                }
                button_child = new CategoryButton(button_desc);
                button_child.category_clicked.connect((i) => {
                    category_choosed (i);
                });
            
                box_child.pack_start(button_child, true, true, 0);
                button_child.show_all();
                
                actual_col++;
            }
            
            while (actual_col != columns) {
                button_child = new CategoryButton(new AppStore.Category("", "", "", "", 0), true);
                box_child.pack_start(button_child, true, true, 0);
                button_child.show_all();
                actual_col++;
            }
        }
        
        public CategoriesView () {
            base("Categories");
            columns = 0;
            actual_col = 0;
            
            box_child = new Box(Orientation.HORIZONTAL, 6);
            box_child.homogeneous = true;
            grid_pack_start(box_child, true, true, 0);
            
            notify["columns"].connect(reconfigure_grid);
        }
    }
}

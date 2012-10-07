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
using Cairo;
using Lsc.Utils;

namespace Lsc.Widgets {
    public class  GridView : BlankBox {
        // Widgets
        public Box container;
        private Separator separator;
        private Label title_label;
        
        // Vars
        public string title {
            set {
                title_label.label = "<span size='large'><b>"+Utils.escape_text (value)+"</b></span>";
            }
        }
        
        public void grid_pack_start (Widget widget, bool expand, bool fill, int space) {
            container.pack_start(widget, expand, fill, space);
        }
        
        private void pack_separator () {
            separator = new Separator(Orientation.HORIZONTAL);
            
            pack_start(separator, false, false, 0);
        }
        
        public GridView (string title) {
            base(Orientation.VERTICAL, 0, 12);
            
            container = new Box(Orientation.VERTICAL, 6);
            container.margin_top = 6;
            
            title_label = new Label("");
            title_label.use_markup = true;
            title_label.halign = Align.START;
            
            this.title = title;
            
            pack_start(title_label, false, false, 0);
            pack_start(container, false, false, 0);
        }
    }
}

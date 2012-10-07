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
using PackageKit;

namespace Lsc.Widgets {
    public class AppsTree : TreeView {
        // Signals
        public signal void selected_row (AppStore.ModelApp app);
        public signal void activated_row (AppStore.ModelApp app);
        
        // Vars
        private IconTheme theme;
        private new ListStore model;
        private TreeIter iter;
        private new TreePath path;
        
        public void append_app (AppStore.ModelApp app) {            
            model.append(out iter);
            //model.set(iter, 0, app.icon, 1, "<span size='medium'>"+Utils.escape_text (app.name)+"</span>\n<span size='small'>"+Utils.escape_text (app.summary)+"</span>", 2, app);
            model.set(iter, 0, app.icon, 1, "<b>"+Utils.escape_text (app.name)+"</b>\n"+Utils.escape_text (app.description), 2, app); // FIXME: this actually take time
        }
        
        public void clear () {
            model.clear();
        }
        
        public void on_cursor_changed (TreeView widget) {
            get_cursor(out path, null);
            if (path != null) {
                AppStore.ModelApp val;
                model.get_iter(out iter, path);
                model.get(iter, 2, out val);
                selected_row(val);
            }
        }
        
        public void on_row_activated (TreePath path, TreeViewColumn column) {
            get_cursor(out this.path, null);
            if (path != null) {
                AppStore.ModelApp val;
                model.get_iter(out iter, this.path);
                model.get(iter, 2, out val);
                activated_row(val);
            }
        }
        
        public AppsTree () {
			theme = IconTheme.get_default ();
			theme.append_search_path ("/usr/share/app-install/icons");
			
			Type t_string = typeof (string);
            model = new ListStore(3,
                t_string, // Icon name
                t_string, // Name and description
                typeof (AppStore.ModelApp)  // id
            );
            
            set_model(model);
            
            CellRendererPixbuf icon_cell = new CellRendererPixbuf();
            icon_cell.height = 56;
            icon_cell.width = 56;
            icon_cell.stock_size = IconSize.DIALOG;
            
            CellRendererText text = new CellRendererText();
            text.ellipsize = Pango.EllipsizeMode.END;
            
            insert_column_with_attributes(-1, "Icon", icon_cell, "icon-name", 0);
            insert_column_with_attributes(-1, "Name", text, "markup", 1);
            
            get_column(1).set_sort_column_id(1);
            get_column(1).set_expand(true);
            get_column(1).clicked();
            
            rules_hint = true;
            
            cursor_changed.connect(on_cursor_changed);
            row_activated.connect(on_row_activated);
            
            headers_visible = false;
        }
    }
    
    public class AppsView : Box {
        // Widgets
        public AppsTree apps_tree;
        
        public AppsView () {
            orientation = Orientation.VERTICAL;
            
            apps_tree = new AppsTree();
            
            ScrolledWindow apps_tree_scroll = new ScrolledWindow(null, null);
            apps_tree_scroll.set_policy(PolicyType.NEVER, PolicyType.AUTOMATIC);
            apps_tree_scroll.add(apps_tree);
            
            pack_start(apps_tree_scroll, true, true, 0);
        }
    }
}

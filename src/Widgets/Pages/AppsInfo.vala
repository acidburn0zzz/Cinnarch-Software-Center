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
using Lsc.Widgets;
using Granite.Widgets;

namespace Lsc.Pages {
    public class AppsInfo : BlankBox {
        public signal void action_response (AppStore.ActionType type, string id);
        
        private Separator separator;
        public RoundBox reviews_box;
        private StaticNotebook s_nb;
        private Box details_box;
        private Image status_icon;
        private Label status_label;
        private Spinner load_spinner;
        private Image image;
        private Label pkg_name;
        private Label short_description;
        private Label description;
        private Label id;
        private Label version;
        private Label size;
        private Label license;
        private Label url;
        private Button action_button;
        private string pkg_id;
        private AppStore.ActionType action_type;
        
        public void set_action (AppStore.ActionType type) {
            action_type = type;
            switch (type) {
                case AppStore.ActionType.INSTALL:
                    action_button.label = "Install";
                    break;
                case AppStore.ActionType.REMOVE:
                    action_button.label = "Remove";
                    break;
            }
        }
        
        public void set_status (Info data) {
            switch (data) {
                case Info.INSTALLED:
                    status_icon.set_from_stock (Stock.YES, IconSize.MENU);
                    status_label.label = "Installed";
                    set_action (AppStore.ActionType.REMOVE);
                    break;
                default:
                    status_icon.set_from_icon_name ("applications-internet", IconSize.MENU);
                    status_label.label = "Available";
                    set_action (AppStore.ActionType.INSTALL);
                    break;
            }
        }
        
        public void set_details (AppStore.App app) {
            var pkg = app.package;
            
            pkg_id = pkg.get_id();
            
            this.show_children();
            load_spinner.set_visible (false);
            load_spinner.stop();
            reviews_box.set_visible (false);
            
            set_status ((Info)pkg.info);
            
            pkg_name.label = "<span size='x-large'><b>%s</b></span>".printf (app.name);
            short_description.label = "<big>%s</big>".printf (app.summary);
            
            description.label = app.description;
            
            image.set_from_icon_name (app.name, IconSize.DIALOG);
            image.pixel_size = 96;
            
            id.label = pkg.get_name();
            version.label = pkg.get_version();
            
            size.label = Utils.size_to_str ((int) app.size);
            license.label = app.license;
           
            url.label = "<a href=\"%s\">%s</a>".printf (app.url, app.name);
    
            details_box.set_visible (false);
            s_nb.page = 0;
        }
        
        public void emit_action (Button button) {
            action_response (action_type, pkg_id);
        }
        
        public void start_load () {
            this.hide_children();
            load_spinner.set_visible(true);
            load_spinner.start();
        }
        
        public void pack_separator () {
            separator = new Separator(Orientation.HORIZONTAL);
            pack_start(separator, false, false, 0);
        }
        
        public AppsInfo () {
            base (Orientation.VERTICAL, 0, 5);
            
            // Summary Box (icon, name/short_description and install button)
            Box summary_box = new Box(Orientation.HORIZONTAL, 5);
            summary_box.margin_top = 5;
            summary_box.margin_left = 5;
            summary_box.margin_right = 5;
            Box label_box = new Box(Orientation.VERTICAL, 0);
            label_box.valign = Align.CENTER;
            image = new Image.from_stock(Stock.INFO, IconSize.DIALOG);
            image.set_size_request (48, 48);
            summary_box.pack_start(image, false, false, 0);
            
            pkg_name = new Label("<big><b>Application name</b></big>");
            pkg_name.use_markup = true;
            pkg_name.halign = Align.START;
            
            short_description = new Label("Application description");
            /*short_description.wrap = true;
            short_description.wrap_mode = Pango.WrapMode.WORD;*/
            short_description.ellipsize = Pango.EllipsizeMode.END;
            short_description.halign = Align.START;
            short_description.use_markup = true;
            
            label_box.pack_start(pkg_name, false, false, 0);
            label_box.pack_start(short_description, false, false, 0);
            label_box.valign = Align.START;
            label_box.halign = Align.START;
            
            summary_box.pack_start(label_box, true, true, 0);
            
            // Status box
            Box status_box = new Box(Orientation.VERTICAL, 1);
            Box status_box2 = new Box(Orientation.HORIZONTAL, 4);
            
            status_label = new Label("");
            status_label.margin_right = 2;
            status_icon = new Image.from_stock(Stock.YES, IconSize.MENU);
            
            action_button = new Button();
            action_button.clicked.connect (emit_action);
            
            status_box2.pack_start(status_icon, false, false, 0);
            status_box2.pack_start(status_label, false, false, 0);
            
            status_box.pack_start(status_box2, false, false, 0);
            status_box.pack_start(action_button, false, false, 0);
            
            summary_box.pack_start(status_box, false, false, 0);
            
            // Description
            description = new Label("Package description");
            description.margin = 5;
            description.selectable = true;
            description.wrap_mode = Pango.WrapMode.WORD_CHAR;
            //description.justify = Justification.CENTER;
            description.ellipsize = Pango.EllipsizeMode.END;
            description.wrap = true;
            description.valign = Align.CENTER;
            description.halign = Align.CENTER;
            description.vexpand = false;
            
            // Details (version and size)
            details_box = new Box(Orientation.HORIZONTAL, 5);
            details_box.border_width = 5;
            details_box.halign = Align.CENTER;
            details_box.valign = Align.CENTER;
            Box details1 = new Box(Orientation.VERTICAL, 0);
            Box details2 = new Box(Orientation.VERTICAL, 0);
            version = new Label("");
            version.halign = Align.START;
            size = new Label("");
            size.halign = Align.START;
            id = new Label("");
            id.halign = Align.START;
            license = new Label("");
            license.halign = Align.START;
            url = new Label ("");
            url.use_markup = true;
            url.halign = Align.START;
            details2.pack_start(id, false, false, 0);
            details2.pack_start(version, false, false, 0);
            details2.pack_start(size, false, false, 0);
            details2.pack_start(license, false, false, 0);
            details2.pack_start(url, false, false, 0);
            
            Label tmp;
            string[] strings = { "Id", "Version", "Size", "License", "Homepage" };
            foreach (string s in strings) {
                tmp = new Label("<b>%s</b>".printf (s));
                tmp.use_markup = true;
                tmp.halign = Align.END;
                details1.pack_start (tmp, false, false, 0);
            }
            
            details_box.pack_start (details1, false, false, 0);
            details_box.pack_start (details2, false, false, 0);
            
            s_nb = new StaticNotebook ();
            
            // Adding widgets
            pack_start(summary_box, false, false, 0);
            pack_start(s_nb, true, true, 0);
            
            s_nb.append_page (description, new Label ("Description"));
            s_nb.append_page (details_box, new Label ("Info"));
            
            load_spinner = new Spinner();
            load_spinner.set_size_request(32, 32);
            
            pack_start(load_spinner, true, false, 0);
        }
    }
}

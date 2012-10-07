//
//  Copyright © 2011 Avi Romanoff, Allen Lowe, Maxwell Barvian
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
// 
// Code from Granite https://launchpad.net/granite
//

using Gtk;
using Gdk;

namespace Granite.Widgets {

    public class HintedEntry : Gtk.Entry {

        public string hint_string {
            get {
                return placeholder_text;
            }
            set {
                placeholder_text = value;
            }
        }

        public HintedEntry (string hint_string) {
            this.hint_string = hint_string;
        }
    }

    public class SearchBar : HintedEntry {

        private bool is_searching = true;
        private uint timeout_id = 0;

        /**
         * This value handles how much time (in ms) should pass
         * after the user stops typing. By default it is set 
         * to 300 ms.
         **/
        public int pause_delay { get; set; default = 300; }

        /**
         * text_changed () signal is emitted after a short delay,
         * which depends on pause_delay.
         * If you need a synchronous signal without any delay,
         * use changed () method.
         **/
        public signal void text_changed_pause (string text);

        public SearchBar (string hint_string) {
        
            base (hint_string);
            
            primary_icon_name = "edit-find-symbolic";
            
            // Signals and callbacks
            changed.connect (manage_icon);
            changed.connect_after (on_changed);            
            focus_in_event.connect (on_focus_in);
            focus_out_event.connect (on_focus_out);
            icon_press.connect (on_icon_press);
        }

        protected new void hint () {
            is_searching = false;
            set_icon_from_stock (Gtk.EntryIconPosition.SECONDARY, null);
        }
        
        private bool on_focus_in () {
            if (!is_searching) {
                is_searching = false;
            }
            
            return false;
        }

        private bool on_focus_out () {
            if (get_text () == "") {
                is_searching = false;
            }
            
            return false;
        }

        private void manage_icon () {
            if (text != "")
                set_icon_from_gicon (EntryIconPosition.SECONDARY, new ThemedIcon.with_default_fallbacks ("edit-clear-symbolic"));
            else
                set_icon_from_stock (EntryIconPosition.SECONDARY, null);
        }

        private void on_icon_press (EntryIconPosition position) {
            if (position == EntryIconPosition.SECONDARY) {
                is_searching = false;
                text = "";
                set_icon_from_stock (position, null);
                is_searching = true;
            } else {
                if (!is_focus) {
                    is_searching = false;
                }
            }
        }

        private void on_changed () {

            if (timeout_id > 0)
                Source.remove (timeout_id);

            timeout_id = Timeout.add (pause_delay, emit_text_changed);

        }

        private bool emit_text_changed () {

            var terms = get_text ();
            text_changed_pause (terms); // Emit signal

            return Source.remove (timeout_id);

        }

    }

}


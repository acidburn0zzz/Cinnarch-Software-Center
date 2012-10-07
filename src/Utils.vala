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

namespace Lsc.Utils {	
    public string nicer_pkg_name (string pkg_name) {
        return capitalize_str(pkg_name.replace("-", " "));
    }
    
    public string capitalize_str (string str) {
        StringBuilder build = new StringBuilder();
        build.append_unichar(str[0].toupper());
        for (int x = 1; x < str.length; x++) {
            build.append_unichar(str[x]);
        }
        return build.str;
    }
    
    public string escape_text (string val) {
		string to_ret;
		to_ret = Markup.escape_text (val);
		to_ret = val.replace ("&", "&amp;");
	    
	    return to_ret;
	}
	
	public string size_to_str (int size) {
		int kB = 1000;
		if (size < kB) {
			return "%d B".printf (size);
		} else if (size < kB * 1000) {
			return "%d kB".printf (size / 1000);
		} else if (size < kB * 1000 * 1000) {
			return "%d MB".printf (size / (1000 * 1000));
		}
		return "%d".printf (size);
	}
}

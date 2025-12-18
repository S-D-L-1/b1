#!/bin/bash
echo " _______ _            ____            _     _______                       "
echo "|__| |__| |          | _ \           | |   |__| |__|                      "
echo "   | |  | |__  ___   | |_) | ___  ___| |_     | | ___  __ _ _ __ ___   "
echo "   | |  | '_ \/ _ \  |  _ < / _ \/ __| __|    | |/ _ \/ _\ | |_ \ _ \  "
echo "   | |  | | | | __/  | |_) | __/\__ \ |_      | |  __/ (_| | | | | | | "
echo "   |_|  |_| |_|\___| |____/ \___||___/\__|    |_|\___|\__,_|_| |_| |_| "

# Check if noseyparker is installed
if ! command -v noseyparker >/dev/null 2>&1; then
    echo "noseyparker not found, please install it first"
    exit 1
fi
#loop thru files in directory
for file in *; do
    [[ -f "$file" && "$file" != *.sh ]] || continue
    type=$(file "$file")
    echo $type
    #file name
    np() {
    rm -rf datastore.np
    noseyparker scan "$file"
    noseyparker report | awk '
        BEGIN { in_block = 0; }

        /^Finding / {
            if (in_block == 1) { 
                print "\n--- End of Previous Finding ---\n" 
            }
            
            in_block = 1;
            print "\n----------------------------------------\n"
            print $0
            next
        }

        in_block == 1 { 
            print $0 
        }

            /Lines: / {
            # Print the line before stopping
            print $0 
            # Set the state to stop printing
            in_block = 0;
            next
        }
        '
    }
    if echo "$type" | grep -qi 'executable'; then
        echo "type is binary, running np scan"
        np
    elif echo "$type" | grep -qi 'data'; then
        echo "type is data, running binwalk"
        binwalk -e "$file" > /dev/null 2>&1
        extracted="_${file}.extracted"
        busybox=$(find "$extracted" -type f -exec strings {} + 2>/dev/null | grep "BusyBox v" | head -n1)
        if [[ -n "$busybox" ]]; then
            echo "BusyBox version: $busybox"
        fi
        passwd=$(find "$extracted" -type f -iname '*passwd*' 2>/dev/null | head -n5)
        if [[ -n "$passwd" ]]; then
            echo "possible password files: $passwd"
        fi
        init=$(find "$extracted" -type f -exec grep -E "(init\.d|rc\.d|/etc/init|/etc/rc\.d)" {} + 2>/dev/null | head -n5)
        if [[ -n "$init" ]]; then
            echo "possible init scripts: $init"
        fi
        key=$(find "$extracted" -type f -exec grep "PRIVATE KEY-----" {} + 2>/dev/null)
        if [[ -n "$key" ]]; then
            echo "possible private keys: $key"
        fi
        np
    else
        echo "type is unknown, skipping"
    fi
done
        

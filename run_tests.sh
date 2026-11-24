#!/bin/bash
pass=0; fail=0
for f in tests/*.gom; do
    exp="${f%.gom}.expected"
    [ -f "$exp" ] || continue
    if diff -q <(./build/hlvm "$f" 2>&1) "$exp" > /dev/null; then
        pass=$((pass+1))
    else
        echo "FAIL: $f"
        fail=$((fail+1))
    fi
done
echo "$pass passed, $fail failed"
[ $fail -eq 0 ]
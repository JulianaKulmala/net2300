#!/bin/bash
multiply() {
product=$(( $1 * $2 ))
echo $product
return 0
}
result=$(multiply 4 5)
echo "Product: $result"


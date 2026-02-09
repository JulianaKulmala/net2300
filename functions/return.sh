function func_return_value {
  echo 20
  return 10
}
func_return_value 
echo "Value returned by function is: $?"


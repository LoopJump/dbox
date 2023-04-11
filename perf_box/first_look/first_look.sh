
LEADING_BLANKS="    "

function print_cmd()
{
  echo -e "\n$LEADING_BLANKS\033[31m $ $1\033[0m"
}

function check_huge_page()
{
  echo "Check Huge Page"
  print_cmd "cat /proc/meminfo | grep Huge"
  cat /proc/meminfo | grep Huge | awk -v LB="$LEADING_BLANKS" '{print LB" "$0}'
}

function check_numa()
{
  echo "Check Numa"
  print_cmd "numastat"
  numastat | awk -v LB="$LEADING_BLANKS" '{print LB" "$0}'
  print_cmd "numastat -m"
  numastat -m | awk -v LB="$LEADING_BLANKS" '{print LB" "$0}'
}

function prompt()
{
  echo "Other prompt:"
  echo "$LEADING_BLANKS glance"
  echo "$LEADING_BLANKS nmon"
  echo "$LEADING_BLANKS htop"
}

function println()
{
  echo "========================================================"
}

println
check_huge_page
println
check_numa
println
prompt
println

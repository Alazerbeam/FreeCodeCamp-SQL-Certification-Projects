PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

MAIN() {
  # if no arg provided
  if [[ -z $1 ]]
  then
    echo "Please provide an element as an argument."
    return
  fi

  # if arg exists, determine its type and find it
  if [[ $1 =~ [0-9]+ ]]
  then
    FIND $1 "atomic_number"
  elif [[ $(echo -n "$1" | wc -m) -le 2 ]]
  then
    FIND $1 "symbol"
  else
    FIND $1 "name"
  fi

  # store the found atomic number
  ATOMIC_NUMBER=$?

  # if invalid element
  if [[ $ATOMIC_NUMBER -eq 0 ]]
  then
    echo "I could not find that element in the database."
    return
  fi

  # if valid, get and print information
  ELEMENT_INFO=$($PSQL "select atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius \
  from properties inner join elements using (atomic_number) \
  inner join types using (type_id) where atomic_number = $ATOMIC_NUMBER")

  echo $ELEMENT_INFO | sed -E 's/\|/ /g' | while read ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_PT BOILING_PT
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_PT celsius and a boiling point of $BOILING_PT celsius."
  done
}

FIND() {
  # $1 = raw input, $2 = type of input (number, symbol, name)
  # return atomic number if found
  if [[ $2 == "atomic_number" ]]
  then
    FORMATTED_INPUT=$1
  else
    FORMATTED_INPUT="'$1'"
  fi
  ATOMIC_NUMBER=$($PSQL "select atomic_number from elements where $2 = $FORMATTED_INPUT")
  return $ATOMIC_NUMBER
}

MAIN $1

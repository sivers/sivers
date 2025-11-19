#!/usr/bin/awk -f

/create table/ {
    current_table = $3
}

/-- references/ {
    column = $1
    # Extract the part after "-- references"
    reference = $0
    sub(/.*-- references /, "", reference)
    sub(/ --.*/, "", reference)  # Remove any trailing comment
    sub(/[[:space:]]+$/, "", reference)  # Trim trailing space

    printf "alter table %s add foreign key (%s) references %s;\n", current_table, column, reference
}

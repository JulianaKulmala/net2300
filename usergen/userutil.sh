#!/bin/sh

password="defaultPass123"

create_and_email() {
    echo "Combined value: $1"
    fullname=$(echo $1 | awk -F, '{print $1}')
    email=$(echo $1 | awk -F, '{print $2}')
    #read fullname email <<< "$(echo "$1" | awk -F, '{print $1, $2}')"
    #IFS=',' read -r fullname email <<< "$1"

    username=$(echo "$fullname" | awk '{print tolower($1)"."tolower($NF)}')
    echo "Creating user: $username with email: $email"
    # Simulate user creation

    useradd -m "$username"
    echo "$password" | sudo passwd --stdin "$username"

    echo "User $username created successfully."
    mailcredentials "$email" "$username" "$password"
}

mailcredentials() {
    echo "sending email to $1"
    echo "Your user name is: $2, and your password is: $3"
}

awk -F, 'NR > 1 { print $1 "," $4}' net2300.csv | while read combo; do
    create_and_email "$combo"
done

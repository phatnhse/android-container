function install_missing_packages() {
  missing_packages=$(cat android-packages | paste -sd " " -)
  if [ ! -z "$missing_packages" -a "$missing_packages" != " " ]; then
    sdkmanager $missing_packages
    printf "All missing android sdk packages has been installed successfully"
  else
    printf "Empty missing android sdk packages"
  fi
}

install_missing_packages

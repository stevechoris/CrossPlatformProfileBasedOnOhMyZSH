main() {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e

  CHECK_ZSH_INSTALLED=$(grep /zsh$ /etc/shells | wc -l)
  if [ ! $CHECK_ZSH_INSTALLED -ge 1 ]; then
    printf "${YELLOW}Zsh is not installed!${NORMAL} Please install zsh first!\n"
    exit
  fi
  unset CHECK_ZSH_INSTALLED

  if [ ! -n "$ZSH" ]; then
    ZSH=~/.oh-my-zsh
  fi

  if [ ! -d "$ZSH" ]; then
    printf "${YELLOW}You don't have Oh My Zsh installed yet.${NORMAL}\n"
    printf "You should first install Oh My Zsh at: http://ohmyz.sh/.\n"
    exit
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  printf "${BLUE}Cloning Oh My Zsh...${NORMAL}\n"
  hash git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [ "$OSTYPE" = cygwin ]; then
    if git --version | grep msysgit > /dev/null; then
      echo "Error: Windows/MSYS Git is not supported on Cygwin"
      echo "Error: Make sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi

  # Set ZSH_CUSTOM to the path where your custom config files
  # and plugins exists, or else we will use the default custom/
  if [ -z "$ZSH_CUSTOM" ]; then
      ZSH_CUSTOM="$ZSH/custom"
  fi

  # Set ZSH_CUSTOM_PROFILE_ADDON to the folder of CrossPlatformProfileBasedOnOnMyZSH
  # under $ZSH_CUSTOM
  ZSH_CUSTOM_PROFILE_ADDON=$ZSH_CUSTOM/CrossPlatformProfileBasedOnOhMyZsh
  echo "ZSH_CUSTOM_PROFILE_ADDON path: $ZSH_CUSTOM_PROFILE_ADDON"

  env git clone --depth=1 https://github.com/stevechoris/CrossPlatformProfileBasedOnOhMyZsh.git $ZSH_CUSTOM_PROFILE_ADDON || {
    printf "Error: git clone of CrossPlatformProfileBasedOnOhMyZsh repo failed\n"
    exit 1
  }
  
  sed -i -e 's/.*ZSH_CUSTOM=.*/ZSH_CUSTOM=$ZSH\/custom\/CrossPlatformProfileBasedOnOhMyZsh/g'  ~/.zshrc

  
  printf "${GREEN}"
  echo 'CrossPlatformProfileBasedOnOhMyZsh is now installed!'
  printf "${NORMAL}"
  env zsh
}

main

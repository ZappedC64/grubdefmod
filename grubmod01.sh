#! /usr/bin/env bash
#
# Check grub for necessary SAP values.
# You would think that 'grubby' would
# modify /etc/default/grub, but it does not.

# Setup ANSI colors. Yeah, that's the way I roll!
green='\033[1;32m'  # ${green}
cyan='\033[1;36m'   # ${cyan}
red='\033[1;31m'    # ${red}
yellow='\033[1;33m' # ${yellow}
nc='\033[0m'        # ${nc} - no color
el='\033[2K'        # ${el} - erase line

# I noticed that some Linux distributions use GRUB_CMDLINE_LINUX
# and some use GRUB_CMDLINE_LINUX_DEFAULT
if grep -Fxq "GRUB_CMDLINE_LINUX" /etc/default/grub; then
   GRUBCL=$(grep "GRUB_CMDLINE_LINUX" /etc/default/grub) # Read just the line we want
else
   GRUBCL=$(grep "GRUB_CMDLINE_LINUX_DEFAULT" /etc/default/grub) # Read just the line we want
fi

GRUBCLITEMS=$(echo $GRUBCL | awk -F\" '{print $2}') # Take just the text
arrGRUB=($GRUBCLITEMS) # Convert to array
GRUBEDIT=0 # Set to 0. Change to 1 if any edits are made

echo "--------------------------------------------------"
function grubmod {
  GRUBCHECK=$1
  if (printf '%s\n' "${arrGRUB[@]}" | grep -xq $GRUBCHECK); then
    echo -e "${cyan}OK: ${yellow}[${green}$GRUBCHECK${yellow}]${cyan} is in ${green}/etc/default/grub${nc}"
  else
    echo -e "${yellow}Adding: ${yellow}[${green}$GRUBCHECK${yellow}]${cyan} to ${green}/etc/default/grub${nc}"
    arrGRUB+=($GRUBCHECK)
    GRUBEDIT=1
  fi
}

grubmod "numa_balancing=disable"
grubmod "transparent_hugepage=never"
grubmod "intel_idle.max_cstate=1"
grubmod "processor.max_cstate=1"
grubmod "elevator=noop" # This is for a VMware VM. The hypervisor controls this setting.
echo "--------------------------------------------------"
function join { local IFS="$1"; shift; echo "$*"; }

GRUBNEW=$(join " " ${arrGRUB[@]})

if grep -Fxq "GRUB_CMDLINE_LINUX" /etc/default/grub; then
   GRUBCLNEW="GRUB_CMDLINE_LINUX=\"$GRUBNEW\""
else
   GRUBCLNEW="GRUB_CMDLINE_LINUX_DEFAULT=\"$GRUBNEW\""
fi

## If any editing was done, update the /etc/default/grub file
if [ $GRUBEDIT -gt 0 ]; then
   if grep -Fxq "GRUB_CMDLINE_LINUX" /etc/default/grub; then
     ## Updating GRUB_CMDLINE_LINUX value in /etc/default/grub file #####
     echo -e "${yellow}Updating GRUB_CMDLINE_LINUX value in /etc/default/grub file...${nc}"
     sed -i "s|GRUB_CMDLINE_LINUX.*|$GRUBCLNEW|" /etc/default/grub
     grub2-mkconfig -o /boot/grub2/grub.cfg
   else
     ## Updating GRUB_CMDLINE_LINUX_DEFAULT value in /etc/default/grub file #####
     echo -e "${yellow}Updating GRUB_CMDLINE_LINUX_DEFAULT value in /etc/default/grub file...${nc}"
     sed -i "s|GRUB_CMDLINE_LINUX_DEFAULT.*|$GRUBCLNEW|" /etc/default/grub
     grub2-mkconfig -o /boot/grub2/grub.cfg
   fi
fi
echo -e "${cyan}[${green} Done ${cyan}]${nc}\n"


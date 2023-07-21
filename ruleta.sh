#!/bin/bash

#Colores
greenColour="\033[1;32m"
endColour="\033[0m"
redColour="\033[1;31m"
blueColour="\033[1;34m"
yellowColour="\033[1;33m"
purpleColour="\033[1;35m"
turquoiseColour="\033[1;36m"
grayColour="\033[1;37m"

#Ctrl+C
trap ctrl_c INT

#Funciones
function ctrl_c()
{
  echo -e "\n${redColour}[!] ${endColour}${yellowColour}Saliendo...${endColour}\n"
  tput cnorm
  exit 1
}

function helpPanel()
{
  echo -e "\n${yellowColour}[+] ${endColour}${grayColour}Uso:${endColour}"
  echo -e "\t${yellowColour}[+] ${endColour}${grayColour}-m)Para definir la cantidad de dinero${endColour}"
  echo -e "\t${yellowColour}[+] ${endColour}${grayColour}-t)Tecnica a emplear (${endColour}${purpleColour}martingala||inverselabrouchere${endColour}${grayColour})${endColour}"
}

function martingala()
{
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Dinero actual:${endColour}${greenColour} $money€ ${endColour} \n"
  echo -ne "${yellowColour}[+]${endColour}${grayColour}¿Cuanto dinero quieres apostar? ->${endColour} " && read initial_bet
  echo -ne "${yellowColour}[+]${endColour}${grayColour}¿A que deseas apostar continuamente?${endColour}${purpleColour}(par/impar)${endColour}${grayColour} -> ${endColour} " && read par_impar
  echo -e "${yellowColour}[+]${endColour}${grayColour}Vamos a jugar con una cantidad inicial de ${endColour}${greenColour}$initial_bet€ ${endColour}${grayColour} a ${endColour}${greenColour} $par_impar ${endColour}"

  tput civis
  backup_bet=$initial_bet
  play_counter=0;
  fail_plays="[ "

  while true
  do
    money=$(($money-$initial_bet)) 
    #echo -e "\n${yellowColour}[+]${endColour}${grayColour}Acabas de apostar${endColour}${greenColour} $initial_bet€ ${endColour}${grayColour} a ${endColour}${greenColour}$par_impar ${endColour}${grayColour}y tu saldo es${endColour}${greenColour} $money€ ${endColour}"
    Nrand=$(($RANDOM % 37))
    #echo -e "---Ha salido -> $Nrand"

    if [ ! "$money" -lt 0 ]
    then	
      if [ "$par_impar" == "par" ]
      then

        if [ $(($Nrand % 2)) -eq 0 ]
        then
          if [ $Nrand -eq 0 ]
          then
            #echo "CERO, ¡PIERDES!"
            #echo "[+]Tu saldo actual es de $money€"
            initial_bet=$(($initial_bet*2))
            fail_plays+="$Nrand "  
          else
            #echo "PAR, ¡GANAS!"
            reward=$(($initial_bet*2))
            #echo "[+]Has ganado un total de $reward€"
            money=$(($money+$reward))
            #echo "[+]Tu saldo actual es de $money€"
            initial_bet=$backup_bet
            fail_plays="[ " 
          fi
        else
          #echo "IMPAR, ¡PIERDES!"
          #echo "[+]Tu saldo actual es de $money€"
          initial_bet=$(($initial_bet*2))
          fail_plays+="$Nrand "
        fi
      else
        if [ $(($Nrand % 2)) -eq 1 ]
        then
          if [ $Nrand -eq 0 ]
          then
            #echo "CERO, ¡PIERDES!"
            #echo "[+]Tu saldo actual es de $money€"
            initial_bet=$(($initial_bet*2))
            fail_plays+="$Nrand "  
          else
            #echo "IMPAR, ¡GANAS!"
            reward=$(($initial_bet*2))
            #echo "[+]Has ganado un total de $reward€"
            money=$(($money+$reward))
            #echo "[+]Tu saldo actual es de $money€"
            initial_bet=$backup_bet
            fail_plays="[ " 
          fi
        else
          #echo "PAR, ¡PIERDES!"
          #echo "[+]Tu saldo actual es de $money€"
          initial_bet=$(($initial_bet*2))
          fail_plays+="$Nrand "
        fi
      fi
    else
      echo -e "\n${redColour}[-]${endColour}${grayColour}No tienes dinero para seguir apostando${endColour}"
      echo -e "${yellowColour}[+]${endColour}${grayColour}Se han realizado un total de${endColour}${greenColour} $play_counter ${endColour}${grayColour}jugadas${endColour}"
      echo -e "\t${redColour}-${endColour}${grayColour}Se han realizado las siguentes malas jugadas consecutivas${endColour}${redColour} $fail_plays${endColour}${grayColour}]${endColour}"
      tput cnorm
      exit 0
    fi

    let play_counter+=1
  done

  tput cnorm
}

function inverselabrouchere()
{
  echo -e "\n[+] Dinero actual: $money€ \n"
  echo -n "[+] ¿A que deseas apostar continuamente? (par/impar) -> " && read par_impar

  declare -a my_sequence=(1 2 3 4)

  echo -e "\n[+] Comenzamos con la secuencia [${my_sequence[@]}]"

  bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
  jugadas_totales=0
  bet_to_renew=$(($money+50))

  echo -e "El tope para renovar la secuenca esta establecido por encima $bet_to_renew€"

  tput civis

  while true
  do
    let jugadas_totales+=1
    Nrand=$(($RANDOM % 37))

    money=$(($money-$bet))

    if [ ! "$money" -lt 0 ]
    then

      #echo -e "\n[+] Invertimos $bet€"
      #echo -e "[+] Tenemos $money€"
      #echo -e "[+] Ha salido el numero $Nrand"


      if [ "${par_impar,,}" == "par" ]
      then
        if [ $(($Nrand % 2)) -eq 0 ] && [ "$Nrand" -ne 0 ]
        then
          #echo -e "PAR,¡GANAS!"
          reward=$(($bet*2))
          let money+=$reward
          #echo -e "Tienes $money€"

          if [ $money -gt $bet_to_renew ]
          then
            #echo -e "Se ha superado el tope establecido de $bet_to_renew€ para recuperar nuestra secuencia"
            let bet_to_renew+=50
            #echo -e "El tope para renovar la secuenca se ha establecido en $bet_to_renew€"
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            #echo -e "La secuencia ha sida restablecida a: [${my_sequence[@]}]"
          else
            my_sequence+=($bet)
            my_sequence=(${my_sequence[@]})

            #echo -e "[+] Nuestra secuencia se queda en [${my_sequence[@]}]"

            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]
            then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]
            then
              bet=${my_sequence[0]}
            else
              #echo -e "[+]Hemos perdido nuestra secuencia"
              my_sequence=(1 2 3 4)
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
              #echo -e "[+]Restablecemos la secuencia a [${my_sequence[@]}]"
            fi
          fi
        elif [ $(($Nrand % 2)) -eq 1 ] || [ "$Nrand" -eq 0 ]
        then

          if [ $(($Nrand % 2)) -eq 1 ]
          then
            #echo -e "IMPAR,¡PIERDES!"
          else
            #echo -e "CERO,¡PIERDES!"
          fi

          if [ $money -lt $(($bet_to_renew-100)) ]
          then
            #echo -e "[+]Hemos llegado a un minimo critico,se procede a reajustar el tope"
            bet_to_renew=$(($bet_to_renew - 50))
            #echo -e "[+]El tope ha sido renovado a $bet_to_renew€"
            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null
            my_sequence=(${my_sequence[@]})

            #echo -e "[+] Nuestra secuencia se queda en [${my_sequence[@]}]"

            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]
            then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]
            then
              bet=${my_sequence[0]}
            else
              #echo -e "[+]Hemos perdido nuestra secuencia"
              my_sequence=(1 2 3 4)
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
              #echo -e "[+]Restablecemos la secuencia a [${my_sequence[@]}]"
            fi
          else

            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null

            my_sequence=(${my_sequence[@]})

            #echo -e "[+] Nuestra secuencia se queda en [${my_sequence[@]}]"

            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]
            then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]
            then
              bet=${my_sequence[0]}
            else
              #echo -e "[+]Hemos perdido nuestra secuencia"
              my_sequence=(1 2 3 4)
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
              #echo -e "[+]Restablecemos la secuencia a [${my_sequence[@]}]"
            fi
          fi
        fi
      else
        if [ $(($Nrand % 2)) -eq 1 ] || [ "$Nrand" -eq 0 ]
        then

          if [ $(($Nrand % 2)) -eq 1 ]
          then
            #echo -e "\n IMPAR,¡GANAS!"
          else
            #echo -e "\n CERO,¡GANAS!"
          fi    
          reward=$(($bet*2))
          let money+=$reward
          #echo -e "Tienes $money€"

          if [ $money -gt $bet_to_renew ]
          then
            #echo -e "Se ha superado el tope establecido de $bet_to_renew€ para recuperar nuestra secuencia"
            let bet_to_renew+=50
            #echo -e "El tope para renovar la secuenca se ha establecido en $bet_to_renew€"
            my_sequence=(1 2 3 4)
            bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            #echo -e "La secuencia ha sida restablecida a: [${my_sequence[@]}]"

          else
            my_sequence+=($bet)
            my_sequence=(${my_sequence[@]})

            #echo -e "[+] Nuestra secuencia se queda en [${my_sequence[@]}]"

            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]
            then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]
            then
              bet=${my_sequence[0]}
            else
              #echo -e "[+]Hemos perdido nuestra secuencia"
              my_sequence=(1 2 3 4)
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
              #echo -e "[+]Restablecemos la secuencia a [${my_sequence[@]}]"
            fi
          fi 

        elif [ $(($Nrand % 2)) -eq 0 ] && [ "$Nrand" -ne 0 ]
        then

          #echo -e "\n PAR,¡PIERDES!"

          unset my_sequence[0]
          unset my_sequence[-1] 2>/dev/null

          my_sequence=(${my_sequence[@]})

          #echo -e "[+] Nuestra secuencia se queda en [${my_sequence[@]}]"

          if [ $money -lt $(($bet_to_renew-100)) ]
          then
            #echo -e "[+]Hemos llegado a un minimo critico,se procede a reajustar el tope"
            bet_to_renew=$(($bet_to_renew - 50))
            #echo -e "[+]El tope ha sido renovado a $bet_to_renew€"
            unset my_sequence[0]
            unset my_sequence[-1] 2>/dev/null
            my_sequence=(${my_sequence[@]})

            #echo -e "[+] Nuestra secuencia se queda en [${my_sequence[@]}]"

            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]
            then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]
            then
              bet=${my_sequence[0]}
            else
              #echo -e "[+]Hemos perdido nuestra secuencia"
              my_sequence=(1 2 3 4)
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
              #echo -e "[+]Restablecemos la secuencia a [${my_sequence[@]}]"
            fi
          else
            if [ "${#my_sequence[@]}" -ne 1 ] && [ "${#my_sequence[@]}" -ne 0 ]
            then
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
            elif [ "${#my_sequence[@]}" -eq 1 ]
            then
              bet=${my_sequence[0]}
            else
              #echo -e "[+]Hemos perdido nuestra secuencia"
              my_sequence=(1 2 3 4)
              bet=$((${my_sequence[0]} + ${my_sequence[-1]}))
              #echo -e "[+]Restablecemos la secuencia a [${my_sequence[@]}]"
            fi
          fi
        fi
      fi
    else
      echo -e "\n${redColour}[-]${endColour}${grayColour}No tienes dinero para seguir apostando${endColour}"
      echo -e "${yellowColour}[+]${endColour}${grayColour}Se han realizado un total de${endColour}${greenColour} $jugadas_totales ${endColour}${grayColour}jugadas${endColour}"
      tput cnorm
      exit 1
    fi

  done
  tput cnorm

}


while getopts "m:t:h" arg
do
  case $arg in
    m) money=$OPTARG;;
    t) tecnica=$OPTARG;;
    h) helpPanel;;
  esac
done

if [ "$money" ] && [[ "$money" =~ ^[0-9]{1,5}+$ ]] && [ "$tecnica" ] 
then

  if [ "${tecnica,,}" == "martingala" ]
  then
    martingala
  elif [ "${tecnica,,}" == "inverselabrouchere" ]
  then
    inverselabrouchere
  else
    echo -e "\n${redColour}[!] ${endColour}${grayColour}La tecnica introducida ${redColour}$tecnica${endColour}${grayColour} no es valida${endColour}"
    helpPanel
  fi

else
  echo -e "\n${redColour}[!] ${endColour}${grayColour}Revise los parametros introducidos ${redColour}$money||$tecnica${endColour}${grayColour} contienen errorres${endColour}"
  helpPanel
fi



#to execute %Diff_comecrent between 2 nc file

### --------------------- User Input -----------------------###

Resolution=05x05				#Input Resolution from GEOSchem simulation
execute=Y
Season_Ex=Y
Year_Ex=N
csv=N
#echo 'Please input Scenario :'
#read assum
#echo "Current Scenario is $assum"
#sleep 5
#echo "Let's get strat"
#Scenario=$assum           #Assumption Scenarios Name

echo "The resolution is ${Resolution}"
echo "Execute or not? (${execute})"
echo "Season or not? (${Season_Ex})"
echo "Year or not? (${Year_Ex})"e
echo "Export .csv file or not? (${csv})"
echo "Let's go!!!"

### --------------------- User Input -----------------------###
for Scenario in SSP2_500C_CACN_DAC_DEMFWR SSP2_BaU_DEMFWR
do
	for yr in 2030 2050 2100
	do
		if [ ${execute} == "Y" ];
			then
				cd "/Users/tjansakoo/Library/CloudStorage/OneDrive-KyotoUniversity/PhD_KyotoUniv_2024/Analysis/DietaryChange/${Scenario}/${yr}"
				echo "Current Scenario is ${Scenario} ${yr}"
				# Delete directories if they exist
					rm -rf Diff_com Rechange_com Seasoning csv

				# Recreate directories
					mkdir -p Diff_com Rechange_com Seasoning csv

				for Sp in pm25 nh4 nit so4
				do
					if [ ${Season_Ex} == "Y" ];
					then
						DateType=monavg
							infile_Final=${Resolution}_${Scenario}_${yr}_off_off_${Sp}_Surface_Re_${DateType}.nc4

							if [ ${Scenario} == "SSP2_500C_CACN_DAC_DEMFWR" ];
							then
							infile_Initial=../../SSP2_500C_CACN_DAC_NoCC/${yr}/${Resolution}_SSP2_500C_CACN_DAC_NoCC_${yr}_off_off_${Sp}_Surface_Re_${DateType}.nc4	    #Initial value
							else
							infile_Initial=../../SSP2_BaU_NoCC/${yr}/${Resolution}_SSP2_BaU_NoCC_${yr}_off_off_${Sp}_Surface_Re_${DateType}.nc4
							fi

							ncdiff $infile_Final $infile_Initial Diff_com/${Resolution}_${Sp}_${Scenario}_${yr}_Diff_com_${DateType}.nc 					            #Final - Initial
							cdo div Diff_com/${Resolution}_${Sp}_${Scenario}_${yr}_Diff_com_${DateType}.nc $infile_Initial tmp1.nc 									    #%change
							cdo mulc,100 tmp1.nc Rechange_com/${Resolution}_${Sp}_${Scenario}_${yr}_Rechange_com_${DateType}.nc

							for season in DJF MAM JJA SON
							do

								#surface concentration
								cdo selseas,${season} $infile_Final tmp1.nc
								cdo timselmean,3 tmp1.nc Seasoning/${Resolution}_${Sp}_${Scenario}_${yr}_surface_conc_${season}.nc

								#Diff_com
								cdo selseas,${season} Diff_com/${Resolution}_${Sp}_${Scenario}_${yr}_Diff_com_${DateType}.nc tmp1.nc
								cdo timselmean,3 tmp1.nc Seasoning/${Resolution}_${Sp}_${Scenario}_${yr}_Diff_com_${season}.nc

								#relative changing
								cdo selseas,${season} Rechange_com/${Resolution}_${Sp}_${Scenario}_${yr}_Rechange_com_${DateType}.nc tmp1.nc
								cdo timselmean,3 tmp1.nc Seasoning/${Resolution}_${Sp}_${Scenario}_${yr}_Rechange_com_${season}.nc

								rm -f tmp1.nc
							done
					else
						echo Season Execution will be skip!!
					fi

					if [ ${Year_Ex} == "Y" ];
					then

						DateType=yearavg
					    infile_Final=${Resolution}_${Scenario}_${yr}_off_off_${Sp}_Surface_Re_${DateType}.nc4


						if [ ${Scenario} == "SSP2_500C_CACN_DAC_DEMFWR" ];
							then
							infile_Initial=../../SSP2_500C_CACN_DAC_NoCC/${yr}/${Resolution}_SSP2_500C_CACN_DAC_NoCC_${yr}_off_off_${Sp}_Surface_Re_${DateType}.nc4	    #Initial value
							else
							infile_Initial=../../SSP2_BaU_NoCC/${yr}/${Resolution}_SSP2_BaU_NoCC_${yr}_off_off_${Sp}_Surface_Re_${DateType}.nc4
						fi

						ncdiff $infile_Final $infile_Initial Diff_com/${Resolution}_${Sp}_${Scenario}_${yr}_Diff_com_${DateType}.nc 					#Final - Initial
						cdo div Diff_com/${Resolution}_${Sp}_${Scenario}_${yr}_Diff_com_${DateType}.nc $infile_Initial tmp1.nc 									#%change
						cdo mulc,100 tmp1.nc Rechange_com/${Resolution}_${Sp}_${Scenario}_${yr}_Rechange_com_${DateType}.nc
						rm -f tmp1.nc
					else
						echo Year Execution will be skip!!
					fi
				done
			else
				echo Execution Skip!!!
		fi

		if [ ${csv} == "Y" ]; then
			#cdo outputtab
		  for i in Diff_com Rechange_com 
			do
				cd "/Users/tjansakoo/Library/CloudStorage/OneDrive-KyotoUniversity/PhD_KyotoUniv_2024/Analysis/DietaryChange/${Scenario}/${yr}"
				for file in *yearavg.nc;
				do
					filename=`echo ${file} | sed "s/\.nc.*/.txt/"`
	        		filenamecsv=`echo ${file} | sed "s/\.nc.*/.csv/"`
	        		echo now : ${filename}
	        		cdo -outputtab,year,name,month,date,lon,lat,value ${file} > ../csv/${filename}
					gsed -i '$d' ../csv/${filename}
					awk '{$1=""; print $0}' ../csv/${filename} > ../csv/tmp1.txt
          			gsed -i 1d ../csv/tmp1.txt
          			gsed -i "s/$/ ${Scenario}/" ../csv/tmp1.txt
          			gsed -i "s/$/ ${yr}/" ../csv/tmp1.txt
	        		gsed -i "1s/^/name month date lon lat value scenario yr\n/" ../csv/tmp1.txt
					cp ../csv/tmp1.txt ../csv/${filename}
	        		#sed 's/ \+/,/g' ../csv/${filename} > ../csv/${filenamecsv}
	        		rm -f ../csv/tmp1.txt
		  	done
		  done
		fi
	done
done

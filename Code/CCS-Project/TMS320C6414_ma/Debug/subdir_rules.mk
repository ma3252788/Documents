################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
main.obj: ../main.c $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"E:/Hardware/CCS5.5/ccsv5/tools/compiler/c6000_7.4.4/bin/cl6x" -mv64+ --abi=coffabi -g --include_path="E:/Hardware/CCS5.5/ccsv5/tools/compiler/c6000_7.4.4/include" --define=c6421 --display_error_number --diag_warning=225 --diag_wrap=off --preproc_with_compile --preproc_dependency="main.pp" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '



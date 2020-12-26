# Pipelined Small 16 Processor -
- Implemented a MIPS Small 16 Processor
- Converted an accumulator based processor into a register-register/load store processor
- Used Pipelining to avoid hazards and make the processor efficient
# Processor Datapath:
![image](https://user-images.githubusercontent.com/35824714/103159573-d7b03480-477f-11eb-8815-62b461faa477.png)
# Additions to the Processor:
![image](https://user-images.githubusercontent.com/35824714/103159681-31fdc500-4781-11eb-9ad9-a9679534f4a8.png) 
![image](https://user-images.githubusercontent.com/35824714/103159688-46da5880-4781-11eb-85bd-6c1782f055ec.png)
# Possible future improvements:
- Implement a forwarding unit so that it is guarenteed that the instruction entering "EXE" stage gets the correct value (more efficient towards handling data hazards)

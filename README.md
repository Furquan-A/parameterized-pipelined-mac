\# Pipelined MAC in SystemVerilog



A parameterized signed Multiply-Accumulate (MAC) unit designed in SystemVerilog.



\## Operation



The MAC performs:



ACC\_next = ACC + (A × B)



\## Features



\- Parameterized input width

\- Parameterized accumulator width

\- Signed multiplication

\- Pipelined multiplication stage

\- Product register

\- valid\_in / valid\_out signaling

\- Accumulator clear

\- Reset support

\- Parameter legality checking



\## Architecture



A ----\\

&#x20;      MULTIPLIER ---> PRODUCT REGISTER ---> ADDER ---> ACCUMULATOR

B ----/                                      ^

&#x20;                                            |

&#x20;                                            ACC



\## Parameters



\- `INPUT\_WIDTH` - Width of input operands

\- `ACC\_WIDTH` - Width of accumulator

\- `PRODUCT\_WIDTH` - Calculated as `2 \* INPUT\_WIDTH`



\## RTL



The main RTL module is:



```text

Simple\_mac.sv


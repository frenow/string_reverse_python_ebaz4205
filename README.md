# String Reverse - Python EBAZ4205

Sistema de comunicação UART entre PC (Python) e FPGA EBAZ4205 que recebe uma string e retorna a string invertida.

![EBAZ4205 Setup](ebaz4205.jpeg)

## Funcionalidades

### 🔄 Comunicação UART
- **Taxa de Transmissão**: 115200 baud
- **Porta**: COM20 (configurável)
- **Protocolo**: Linha terminada em newline (`\n`)
- Comunicação bidirecional entre host Python e FPGA

### 📝 Processamento de Dados
- Recepção de string via UART até newline
- Buffer de armazenamento de até 256 bytes
- Inversão automática da string recebida
- Transmissão da string invertida de volta ao host

### 💡 Indicadores Visuais (LEDs)
- **LED Verde**: Aceso durante recepção de dados (estado RECEIVE)
- **LED Vermelho**: Aceso durante transmissão de dados (estado SEND)
- Feedback visual do estado operacional em tempo real

## Arquitetura

### Hardware (Verilog)
```
project_ebaz_blink.srcs/sources_1/new/
├── top_blink.v         # Módulo principal com state machine (IDLE → RECEIVE → SEND)
├── uart_rx.v           # Receptor UART com sincronização de baud rate
└── uart_tx.v           # Transmissor UART com serialização de dados
```

**Características do Hardware:**
- Clock: 50 MHz (Zynq)
- Baud Rate: 115200
- Buffer de entrada: 256 bytes
- State Machine: 3 estados (IDLE, RECEIVE, SEND)

### Software (Python)
```
send.py                # Script de comunicação host-FPGA
```

**Funcionalidades:**
- Conexão serial automática
- Envio de strings com timestamp
- Recepção e exibição de resultado invertido
- Tratamento de exceções com retry automático

### Firmware (C - ARM)
```
project_ebaz_blink.sdk/ebaz_blink/src/helloworld.c  # Referência (não utilizado)
```

## Fluxo de Operação

```
1. Host Python conecta à COM20 (115200 baud)
                    ↓
2. Envia: "Emerson Duarte\n"
   LED Verde acende (RECEIVE)
                    ↓
3. FPGA recebe cada byte e armazena no buffer
                    ↓
4. Ao receber newline, inverte a string
   LED Vermelho acende (SEND)
                    ↓
5. FPGA transmite: "etaurD nosrEmE"
                    ↓
6. Host Python recebe e exibe resultado
   LEDs apagam (IDLE)
```

## Como Usar

### Pré-requisitos
- FPGA EBAZ4205 com bitstream programado
- Python 3.6+
- Biblioteca `pyserial`

### Instalação
```bash
pip install pyserial
```

### Execução
```bash
python send.py
```

### Exemplo de Saída
```
14:32:15 : Reverse system from fpga EBAZ4205
14:32:15 : Sent to FPGA: Emerson Duarte
14:32:15 : etaurD nosrEmE
```

## Configuração

### Alterar Porta Serial
Editar `send.py` linha 6:
```python
SERIAL_PORT = 'COM20'  # Alterar conforme necessário
```

### Alterar Taxa de Baud
Python (`send.py` linha 7):
```python
SERIAL_BAUD = 115200
```

FPGA (`top_blink.v` linha 13):
```verilog
parameter UART_FRE = 115200;
```

### Alterar Tamanho do Buffer
FPGA (`top_blink.v` linha 14):
```verilog
parameter BUFFER_SIZE = 256;
```

## Estrutura do Projeto

```
project_ebaz_blink/
├── project_ebaz_blink.xpr              # Projeto Vivado
├── send.py                             # Script Python host
├── README.md                           # Este arquivo
├── project_ebaz_blink.srcs/
│   ├── sources_1/
│   │   └── new/
│   │       ├── top_blink.v             # Módulo principal
│   │       ├── uart_rx.v               # RX UART
│   │       └── uart_tx.v               # TX UART
│   └── constrs_1/
│       └── constr.xdc                  # Constraints Vivado
└── project_ebaz_blink.sdk/
    └── ebaz_blink/
        └── src/
            └── helloworld.c            # Firmware ARM (referência)
```

## Detalhes Técnicos

### State Machine (FPGA)
- **IDLE**: Aguarda início de recepção
- **RECEIVE**: Acumula bytes até newline (`0x0A`)
- **SEND**: Transmite bytes invertidos em sequência

### UART RX (uart_rx.v)
- Detecta borda de descida (start bit)
- Sincroniza com meio do bit
- Recebe 8 bits de dados
- Detecta stop bit

### UART TX (uart_tx.v)
- Envia 1 start bit (0)
- Envia 8 bits de dados (LSB first)
- Envia 1 stop bit (1)
- Aguarda sinal de ready para novo byte

## Status dos LEDs

| Estado | LED Verde | LED Vermelho |
|--------|-----------|--------------|
| IDLE   | ❌ Apago  | ❌ Apago     |
| RECEIVE| ✅ Aceso  | ❌ Apago     |
| SEND   | ❌ Apago  | ✅ Aceso     |

## Requisitos de Hardware

- Placa EBAZ4205 com Zynq-7010
- Conexão UART (USB-Serial ou similar)
- LEDs conectados aos pinos de saída
- Alimentação 3.3V ou 5V (conforme design)

## Licença

MIT License

## Autor

Desenvolvido para EBAZ4205 String Reverse Project

## Histórico de Alterações

### v1.0 (Versão Atual)
- ✅ Implementação completa de RX/TX UART
- ✅ State machine para processamento
- ✅ Indicadores LED para feedback visual
- ✅ Script Python para comunicação host
- ✅ Buffer configurável até 256 bytes
- ✅ Suporte a strings de qualquer comprimento (até buffer limit)

## Troubleshooting

**Problema**: Script Python não conecta à porta COM
- **Solução**: Verificar porta COM correta com `Device Manager` ou `python -m serial.tools.list_ports`

**Problema**: Dados recebidos incorretos
- **Solução**: Verificar taxa de baud (115200), cables e conexões UART

**Problema**: LEDs não piscam
- **Solução**: Verificar se bitstream foi programado corretamente e se pinos estão mapeados em constraints

**Problema**: Buffer transborda
- **Solução**: Aumentar `BUFFER_SIZE` em `top_blink.v` ou enviar strings menores

## Links Úteis

- [EBAZ4205 Wiki](https://github.com/frenow/EBAZ4205)
- [Xilinx Zynq Documentation](https://www.xilinx.com/products/silicon-devices/soc/zynq-7000.html)
- [PySerial Documentation](https://pyserial.readthedocs.io/)

---

**Desenvolvido com ❤️ para EBAZ4205**

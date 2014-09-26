if ([IntPtr]::size -eq 8) {
    echo arch_bits=x86_64
} else {
    echo arch_bits=x86_32
}

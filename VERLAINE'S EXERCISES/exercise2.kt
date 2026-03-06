fun main() {
    val words = listOf("apple", "cat", "banana", "dog", "elephant")

    val wordLengths = words.associateWith { it.length }

    wordLengths
        .filter { it.value > 4 }
        .forEach { println("${it.key} has length ${it.value}") }
}
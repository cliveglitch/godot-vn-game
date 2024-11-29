class_name Trie

var separator_character = null
var root: TrieNode = TrieNode.new()

func insert_word(word: String) -> void:
	var current_node = self.root
	
	for idx in range(word.length()):
		if not current_node.children.has(word[idx]):
			current_node.children[word[idx]] = TrieNode.new()
		current_node = current_node.children[word[idx]]
		
		if idx + 1 < word.length() and word[idx + 1] == separator_character:
			current_node.is_end_char = true
	
	current_node.is_end_char = true

func has(word: String) -> bool:
	var current_node = self.root
	
	for c in word:
		if not current_node.children.has(c):
			return false
		current_node = current_node.children[c]
	
	return current_node.is_end_char

func has_prefrix(prefix: String) -> bool:
	var current_node = self.root
	
	for c in prefix:
		if not current_node.children.has(c):
			return false
		current_node = current_node.children[c]
	
	return true

## Returns null if there are no words with that prefix
## Or if there are more than 1 word with that prefix
func get_word_with_unique_prefix(prefix: String):
	var current_node = self.root
	
	## Start of the prefix in the Trie
	for c in prefix:
		## The prefix doesn't exist
		if not current_node.children.has(c):
			return null
		current_node = current_node.children[c]
	
	if current_node.children.size() > 1:
		return prefix
	
	var current_word = prefix
	
	while current_node.children:
		
		if current_node.children.size() > 1:
			break
		
		var next_node = current_node.children.keys()[0]
		current_node = current_node.children[next_node]
		current_word += next_node
		
		if current_node.is_end_char:
			break
	
	return current_word

func get_all_words_with_prefix(prefix: String):
	var current_node = self.root
	
	## Start of the prefix in the Trie
	for c in prefix:
		## No words in the Trie with that prefix
		if not current_node.children.has(c):
			return []
		current_node = current_node.children[c]
	
	return _get_words_from_trie_node(current_node, prefix)

func _get_words_from_trie_node(node: TrieNode, prefix: String) -> Array[String]:
	var words: Array[String] = []
	
	for child in node.children:
		if child != separator_character:
			words.append_array(_get_words_from_trie_node(node.children[child], prefix + child))
	
	if node.is_end_char:
		words.append(prefix)
	
	return words

class TrieNode:
	var children: Dictionary = {}
	var is_end_char: bool = false

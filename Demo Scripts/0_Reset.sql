------------------------------------------------------
-- Enable trace flags for vector features (CTP 2.1)
------------------------------------------------------
DBCC TRACEON(466, 474, 13981, -1)
GO


/*
1.  Fire up 2025 VMware VM

2.  Start Ollama - can just run from Start Menu

3.  Start nginx
cd C:\Incoming\Ollama_Setup\nginx-1.27.5\
nginx.exe

4.  Test with curl via PowerShell terminal window
curl http://localhost:11434

curl https://localhost

Invoke-RestMethod -Uri https://localhost/api/embeddings `
   -Method Post `
   -Body '{"model": "nomic-embed-text", "prompt": "This is a test sentence to embed."}' `
   -ContentType 'application/json'

curl http://192.168.1.160:11434

curl https://192.168.1.160

Invoke-RestMethod -Uri https://192.168.1.160/api/embeddings `
   -Method Post `
   -Body '{"model": "nomic-embed-text", "prompt": "This is a test sentence to embed."}' `
   -ContentType 'application/json'

Invoke-RestMethod -Uri https://192.168.1.160/api/chat `
   -Method Post `
   -Body '{"model":"llama3.2","stream":false,"messages":[{"role":"system","content":"You are a helpful assistant that summarizes search results to answer user queries. Provide a concise, human-friendly answer based on the provided context."},{"role":"user","content":"Here is my query: How do SQL Server 2025 and Ollama work together for RAG?\\n\\nHere are the relevant search results:\\n[{\"id\":1,\"title\":\"SQL Server 2025 Vector Search Overview\",\"snippet\":\"SQL Server 2025 introduces native vector search capabilities, enabling efficient similarity searches on vector embeddings. This feature is crucial for RAG architectures.\",\"score\":0.95},{\"id\":2,\"title\":\"Ollama Local LLM Setup Guide\",\"snippet\":\"Ollama simplifies running large language models like Llama 3 locally. It provides a user-friendly command-line interface and a REST API for inference.\",\"score\":0.88},{\"id\":3,\"title\":\"JSON Functions in SQL Server\",\"snippet\":\"SQL Server 2025 enhances JSON support with a native JSON data type and improved indexing, making it easier to store, query, and manipulate JSON documents.\",\"score\":0.82},{\"id\":4,\"title\":\"sp_invoke_external_rest_endpoint Usage\",\"snippet\":\"The sp_invoke_external_rest_endpoint procedure in SQL Server 2025 allows direct calls to external REST APIs from T-SQL, supporting various HTTP methods and secure communication.\",\"score\":0.91}]"}]}' `
   -ContentType 'application/json'

*/
-----
-- Pre-populate buffer pool
USE RecipesDemoDB
GO
EXEC dbo.sp_search_recipes 'give me something to eat';
GO
EXEC dbo.sp_search_recipes_description_tags_knn 'give me something to eat';
GO


-----
-- Pre-execute 2a_KNN Searching.sql



/*-----------------------------------------------------------------------------
-- 2a_KNN Searching.sql
--
-- Written By: Andy Yun
-- Created On: 2025-07-22
-- 
-- Summary: 
-- Fun with KNN search
-----------------------------------------------------------------------------*/
USE RecipesDemoDB
GO




-----
-- KNN search is quite expensive
-- ~10 min runtime
SET STATISTICS IO ON
SET STATISTICS TIME ON
GO

SELECT GETDATE();
GO

EXEC dbo.sp_search_recipes_knn 'Find me something to eat that I can cook in 30 minutes or less';
GO

SELECT GETDATE();
GO


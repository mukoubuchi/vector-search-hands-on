#!/usr/bin/env python3
"""
Pythonスクリプトのユニットテスト
"""

import unittest
import sys
import os
from pathlib import Path

# プロジェクトルートをパスに追加
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root / "setup" / "participant"))


class TestConnectionScripts(unittest.TestCase):
    """接続テストスクリプトのテスト"""
    
    def test_imports(self):
        """必要なモジュールがインポートできることを確認"""
        try:
            import test_connection
            import test_embeddings_hf
            self.assertTrue(True, "モジュールのインポートに成功")
        except ImportError as e:
            self.fail(f"モジュールのインポートに失敗: {e}")
    
    def test_env_example_exists(self):
        """環境変数テンプレートファイルが存在することを確認"""
        env_example = project_root / "setup" / "participant" / ".env.example"
        self.assertTrue(env_example.exists(), ".env.exampleファイルが存在する")
    
    def test_requirements_exists(self):
        """requirements.txtが存在することを確認"""
        requirements = project_root / "setup" / "participant" / "requirements.txt"
        self.assertTrue(requirements.exists(), "requirements.txtファイルが存在する")


class TestProjectStructure(unittest.TestCase):
    """プロジェクト構造のテスト"""
    
    def test_lib_directory_exists(self):
        """libディレクトリが存在することを確認"""
        lib_dir = project_root / "lib"
        self.assertTrue(lib_dir.exists(), "libディレクトリが存在する")
        self.assertTrue(lib_dir.is_dir(), "libはディレクトリである")
    
    def test_common_sh_exists(self):
        """common.shが存在することを確認"""
        common_sh = project_root / "lib" / "common.sh"
        self.assertTrue(common_sh.exists(), "common.shファイルが存在する")
    
    def test_deploy_helpers_sh_exists(self):
        """deploy-helpers.shが存在することを確認"""
        deploy_helpers = project_root / "lib" / "deploy-helpers.sh"
        self.assertTrue(deploy_helpers.exists(), "deploy-helpers.shファイルが存在する")
    
    def test_docs_directory_exists(self):
        """docsディレクトリが存在することを確認"""
        docs_dir = project_root / "docs"
        self.assertTrue(docs_dir.exists(), "docsディレクトリが存在する")
        self.assertTrue(docs_dir.is_dir(), "docsはディレクトリである")
    
    def test_mkdocs_yml_exists(self):
        """mkdocs.ymlが存在することを確認"""
        mkdocs_yml = project_root / "mkdocs.yml"
        self.assertTrue(mkdocs_yml.exists(), "mkdocs.ymlファイルが存在する")
    
    def test_readme_exists(self):
        """README.mdが存在することを確認"""
        readme = project_root / "README.md"
        self.assertTrue(readme.exists(), "README.mdファイルが存在する")


class TestScriptPermissions(unittest.TestCase):
    """スクリプトの実行権限テスト"""
    
    def test_start_docs_executable(self):
        """start-docs.shが実行可能であることを確認"""
        script = project_root / "start-docs.sh"
        if script.exists():
            self.assertTrue(os.access(script, os.X_OK), "start-docs.shは実行可能である")
    
    def test_deploy_script_executable(self):
        """deploy-to-code-engine.shが実行可能であることを確認"""
        script = project_root / "deploy-to-code-engine.sh"
        if script.exists():
            self.assertTrue(os.access(script, os.X_OK), "deploy-to-code-engine.shは実行可能である")
    
    def test_instructor_scripts_executable(self):
        """講師用スクリプトが実行可能であることを確認"""
        instructor_dir = project_root / "setup" / "instructor"
        scripts = [
            "start-all.sh",
            "stop-all.sh",
            "check_docs_url.sh",
            "check-deploy-status.sh"
        ]
        
        for script_name in scripts:
            script = instructor_dir / script_name
            if script.exists():
                self.assertTrue(
                    os.access(script, os.X_OK),
                    f"{script_name}は実行可能である"
                )


def run_tests():
    """テストを実行"""
    # テストスイートを作成
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # テストケースを追加
    suite.addTests(loader.loadTestsFromTestCase(TestConnectionScripts))
    suite.addTests(loader.loadTestsFromTestCase(TestProjectStructure))
    suite.addTests(loader.loadTestsFromTestCase(TestScriptPermissions))
    
    # テストを実行
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # 結果を返す
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    sys.exit(run_tests())

# Made with Bob
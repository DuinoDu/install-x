import unittest
import os
import tempfile
import shutil
from unittest.mock import patch, MagicMock
import subprocess
import sys

from install_x.mcp_server import LibraryInstaller, is_supported, install

class TestLibraryInstaller(unittest.TestCase):
    """Test cases for the LibraryInstaller class."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.test_dir = tempfile.mkdtemp()
        self.original_cwd = os.getcwd()
        os.chdir(self.test_dir)
    
    def tearDown(self):
        """Clean up test fixtures."""
        os.chdir(self.original_cwd)
        shutil.rmtree(self.test_dir)
    
    def test_is_supported_known_python_library(self):
        """Test if known Python libraries are detected as supported."""
        self.assertTrue(LibraryInstaller.is_supported('numpy'))
        self.assertTrue(LibraryInstaller.is_supported('pandas'))
        self.assertTrue(LibraryInstaller.is_supported('matplotlib'))
    
    def test_is_supported_known_javascript_library(self):
        """Test if known JavaScript libraries are detected as supported."""
        self.assertTrue(LibraryInstaller.is_supported('express'))
        self.assertTrue(LibraryInstaller.is_supported('lodash'))
        self.assertTrue(LibraryInstaller.is_supported('react'))
    
    def test_is_supported_known_rust_library(self):
        """Test if known Rust libraries are detected as supported."""
        self.assertTrue(LibraryInstaller.is_supported('serde'))
        self.assertTrue(LibraryInstaller.is_supported('tokio'))
        self.assertTrue(LibraryInstaller.is_supported('clap'))
    
    def test_is_supported_unknown_library(self):
        """Test if unknown libraries are detected as not supported."""
        self.assertFalse(LibraryInstaller.is_supported('nonexistent-library-12345'))
    
    def test_is_supported_case_insensitive(self):
        """Test that library name checking is case insensitive."""
        self.assertTrue(LibraryInstaller.is_supported('NUMPY'))
        self.assertTrue(LibraryInstaller.is_supported('NumPy'))
        self.assertTrue(LibraryInstaller.is_supported('  numpy  '))
    
    @patch('subprocess.run')
    def test_install_python_package_success(self, mock_run):
        """Test successful Python package installation."""
        mock_run.return_value = MagicMock(returncode=0, stdout='Successfully installed', stderr='')
        
        result = LibraryInstaller.install('numpy')
        
        self.assertIsInstance(result, dict)
        self.assertIn('success', result)
        self.assertIn('message', result)
    
    @patch('subprocess.run')
    def test_install_python_package_failure(self, mock_run):
        """Test failed Python package installation."""
        mock_run.return_value = MagicMock(returncode=1, stdout='', stderr='Package not found')
        
        result = LibraryInstaller.install('nonexistent-package')
        
        self.assertIsInstance(result, dict)
        self.assertIn('success', result)
        self.assertIn('message', result)
    
    @patch('subprocess.run')
    def test_install_npm_package_success(self, mock_run):
        """Test successful npm package installation."""
        mock_run.side_effect = [
            MagicMock(returncode=0),  # npm init
            MagicMock(returncode=0, stdout='Package installed', stderr='')  # npm install
        ]
        
        # Mock the package checks to return specific results
        with patch.object(LibraryInstaller, '_is_python_package', return_value=False), \
             patch.object(LibraryInstaller, '_is_npm_package', return_value=True), \
             patch.object(LibraryInstaller, '_is_crate', return_value=False):
            
            result = LibraryInstaller.install('lodash')
            
            self.assertIsInstance(result, dict)
            self.assertIn('success', result)
    
    def test_supported_languages_structure(self):
        """Test that the supported languages structure is correct."""
        self.assertIsInstance(LibraryInstaller.SUPPORTED_LANGUAGES, dict)
        
        expected_languages = {'python', 'c', 'cpp', 'rust', 'javascript'}
        actual_languages = set(LibraryInstaller.SUPPORTED_LANGUAGES.keys())
        
        self.assertEqual(actual_languages, expected_languages)
        
        for lang_config in LibraryInstaller.SUPPORTED_LANGUAGES.values():
            self.assertIn('package_managers', lang_config)
            self.assertIn('install_command', lang_config)
            self.assertIn('common_libraries', lang_config)
            self.assertIsInstance(lang_config['common_libraries'], list)
    
    def test_numpy_specific_installation(self):
        """Test numpy installation specifically as requested in PRD."""
        # Test that numpy is supported
        self.assertTrue(LibraryInstaller.is_supported('numpy'))
        
        # Test numpy installation structure
        with patch('subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(returncode=0, stdout='Successfully installed numpy', stderr='')
            
            result = LibraryInstaller.install('numpy')
            
            self.assertIsInstance(result, dict)
            self.assertIn('success', result)
            self.assertIn('message', result)
            
            # Check that pip was called with correct arguments for numpy
            mock_run.assert_called_with([
                sys.executable, '-m', 'pip', 'install', 'numpy'
            ], capture_output=True, text=True, cwd=os.getcwd())

class TestFastMCPTools(unittest.TestCase):
    """Test cases for FastMCP tools."""
    
    def test_is_supported_tool(self):
        """Test the is_supported FastMCP tool."""
        # Test with known library
        result = is_supported("numpy")
        self.assertIsInstance(result, dict)
        self.assertEqual(result["library_name"], "numpy")
        self.assertTrue(result["is_supported"])
        
        # Test with unknown library
        result = is_supported("nonexistent-library-12345")
        self.assertIsInstance(result, dict)
        self.assertEqual(result["library_name"], "nonexistent-library-12345")
        self.assertFalse(result["is_supported"])
    
    def test_install_tool(self):
        """Test the install FastMCP tool."""
        with patch('subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(returncode=0, stdout='Successfully installed', stderr='')
            
            result = install("numpy")
            self.assertIsInstance(result, dict)
            self.assertIn('success', result)
    
    def test_tool_input_validation(self):
        """Test tool input validation."""
        # Test empty library name
        result = is_supported("")
        self.assertIn('error', result)
        
        result = install("")
        self.assertIn('error', result)
    
    def test_tool_case_insensitive(self):
        """Test that tools handle case insensitivity."""
        result1 = is_supported("NUMPY")
        result2 = is_supported("numpy")
        
        self.assertEqual(result1["is_supported"], result2["is_supported"])

class TestMCPIntegration(unittest.TestCase):
    """Test cases for MCP server integration."""
    
    def test_library_installer_class_exists(self):
        """Test that LibraryInstaller class is properly defined."""
        self.assertIsNotNone(LibraryInstaller)
        self.assertTrue(hasattr(LibraryInstaller, 'is_supported'))
        self.assertTrue(hasattr(LibraryInstaller, 'install'))
        self.assertTrue(callable(LibraryInstaller.is_supported))
        self.assertTrue(callable(LibraryInstaller.install))
    
    def test_supported_methods_return_types(self):
        """Test that methods return expected types."""
        result = LibraryInstaller.is_supported('test')
        self.assertIsInstance(result, bool)
        
        with patch('subprocess.run') as mock_run:
            mock_run.return_value = MagicMock(returncode=0, stdout='', stderr='')
            result = LibraryInstaller.install('test')
            self.assertIsInstance(result, dict)

if __name__ == '__main__':
    unittest.main()

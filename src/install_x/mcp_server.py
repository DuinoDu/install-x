import os
import subprocess
import sys
from typing import Dict, Any, List
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("install-x")

INSTALL_DIR = os.path.join(os.path.dirname(__file__), "install")

class LibraryInstaller:
    """Handles library installation for various languages."""
    
    SUPPORTED_LANGUAGES = {
        'python': {
            'supported_libraries': [
                'torch', 'MinkowskiEngine', 'finegrasp_graspnet1b', 'graspnetAPI', 'spconv',
            ]
        },
        'c': {
            'supported_libraries': [
                'ssl', 'crypto', 'curl', 'json-c', 'sqlite3', 'zlib', 
                'png', 'jpeg', 'xml2', 'xslt'
            ]
        },
        'cpp': {
            'supported_libraries': [
                'boost-all-dev', 'opencv-dev', 'eigen3-dev', 'protobuf-dev',
                'grpc-dev', 'tensorflow-dev', 'pcl-dev'
            ]
        },
        'rust': {
            'supported_libraries': [
                'serde', 'tokio', 'reqwest', 'clap', 'anyhow', 'thiserror',
                'axum', 'rocket', 'diesel', 'sqlx'
            ]
        },
        'javascript': {
            'supported_libraries': [
                'express', 'lodash', 'axios', 'react', 'vue', 'angular',
                'typescript', 'webpack', 'jest', 'eslint'
            ]
        }
    }
    
    @classmethod
    def is_supported(cls, library_name: str) -> bool:
        """Check if a library is supported for installation."""
        library_name = library_name.lower().strip()
        
        for lang_config in cls.SUPPORTED_LANGUAGES.values():
            if library_name in [lib.lower() for lib in lang_config['supported_libraries']]:
                return True
        
        return cls._check_general_availability(library_name)
    
    @classmethod
    def _check_general_availability(cls, library_name: str) -> bool:
        """Check if library is generally available through common package managers."""
        try:
            if cls._is_python_package(library_name):
                return True
            if cls._is_npm_package(library_name):
                return True
            if cls._is_crate(library_name):
                return True
        except Exception:
            pass
        return False
    
    @staticmethod
    def _is_python_package(package_name: str) -> bool:
        """Check if package exists on PyPI."""
        try:
            result = subprocess.run([
                sys.executable, '-m', 'pip', 'search', package_name
            ], capture_output=True, text=True, timeout=10)
            return result.returncode == 0
        except subprocess.TimeoutExpired:
            return False
    
    @staticmethod
    def _is_npm_package(package_name: str) -> bool:
        """Check if package exists on npm."""
        try:
            result = subprocess.run([
                'npm', 'view', package_name
            ], capture_output=True, text=True, timeout=10)
            return result.returncode == 0
        except subprocess.TimeoutExpired:
            return False
    
    @staticmethod
    def _is_crate(crate_name: str) -> bool:
        """Check if crate exists on crates.io."""
        try:
            result = subprocess.run([
                'cargo', 'search', crate_name
            ], capture_output=True, text=True, timeout=10)
            return result.returncode == 0 and crate_name in result.stdout
        except subprocess.TimeoutExpired:
            return False
    
    @classmethod
    def install(cls, library_name: str) -> Dict[str, Any]:
        """Install a library in the current directory."""
        library_name = library_name.lower().strip()
        
        if not cls.is_supported(library_name):
            return {
                'success': False,
                'message': f'Library "{library_name}" is not supported for installation'
            }
        
        installation_results = []
        
        # Try Python first
        if cls._is_python_package(library_name):
            result = cls._install_python_package(library_name)
            installation_results.append(result)
        
        # Try npm for JavaScript packages
        if cls._is_npm_package(library_name):
            result = cls._install_npm_package(library_name)
            installation_results.append(result)
        
        # Try Rust for crates
        if cls._is_crate(library_name):
            result = cls._install_rust_crate(library_name)
            installation_results.append(result)
        
        successful_installs = [r for r in installation_results if r['success']]
        
        if successful_installs:
            return {
                'success': True,
                'message': f'Successfully installed {library_name}',
                'details': successful_installs
            }
        else:
            return {
                'success': False,
                'message': f'Failed to install {library_name}',
                'details': installation_results
            }
    
    @staticmethod
    def _install_python_package(package_name: str) -> Dict[str, Any]:
        """Install a Python package using pip."""
        try:
            package_version = ""
            result = subprocess.run([
                "bash", f"{INSTALL_DIR}/{package_name}.sh", package_version
            ], capture_output=True, text=True, cwd=os.getcwd())
            
            return {
                'language': 'python',
                'success': result.returncode == 0,
                'stdout': result.stdout,
                'stderr': result.stderr
            }
        except Exception as e:
            return {
                'language': 'python',
                'success': False,
                'error': str(e)
            }
    
    @staticmethod
    def _install_npm_package(package_name: str) -> Dict[str, Any]:
        """Install an npm package."""
        try:
            if not os.path.exists('package.json'):
                subprocess.run(['npm', 'init', '-y'], capture_output=True)
            
            result = subprocess.run([
                'npm', 'install', package_name
            ], capture_output=True, text=True, cwd=os.getcwd())
            
            return {
                'language': 'javascript',
                'success': result.returncode == 0,
                'stdout': result.stdout,
                'stderr': result.stderr
            }
        except Exception as e:
            return {
                'language': 'javascript',
                'success': False,
                'error': str(e)
            }
    
    @staticmethod
    def _install_rust_crate(crate_name: str) -> Dict[str, Any]:
        """Install a Rust crate."""
        try:
            if not os.path.exists('Cargo.toml'):
                subprocess.run(['cargo', 'init', '--name', 'temp_project'], 
                             capture_output=True)
            
            result = subprocess.run([
                'cargo', 'add', crate_name
            ], capture_output=True, text=True, cwd=os.getcwd())
            
            return {
                'language': 'rust',
                'success': result.returncode == 0,
                'stdout': result.stdout,
                'stderr': result.stderr
            }
        except Exception as e:
            return {
                'language': 'rust',
                'success': False,
                'error': str(e)
            }

@mcp.tool()
def is_supported(library_name: str) -> Dict[str, Any]:
    """Check if a library is supported for installation."""
    library_name = library_name.strip()
    if not library_name:
        return {"error": "library_name is required"}
    
    supported = LibraryInstaller.is_supported(library_name)
    return {
        "library_name": library_name,
        "is_supported": supported
    }

@mcp.tool()
def install(library_name: str) -> Dict[str, Any]:
    """Install a library in the current directory."""
    library_name = library_name.strip()
    if not library_name:
        return {"error": "library_name is required"}
    
    return LibraryInstaller.install(library_name)

if __name__ == "__main__":
    mcp.run()

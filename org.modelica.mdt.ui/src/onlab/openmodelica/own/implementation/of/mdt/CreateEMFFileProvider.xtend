
package onlab.openmodelica.own.implementation.of.mdt

import java.io.IOException
import openmodelica.Package
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.util.BasicExtendedMetaData
import org.eclipse.emf.ecore.xmi.XMLResource

class CreateEMFFileProvider {	
	
	def createEMFFile(ResourceSet resSet, Package rootPackage, IPath filePath, String fileName) {		
		val eclipseProject = getContainingProject(filePath)

		val fmuXmlUri = URI.createPlatformResourceURI(eclipseProject.name + 
			"/generated/" + fileName + ".openmodelica", true);		

		val resource = getOrCreateResource(fmuXmlUri, resSet)
		resource.contents.add(rootPackage)
		
		val metadata = new BasicExtendedMetaData

		saveResource(resource, metadata)
	}

	private def getContainingProject(IPath filePath) {		
		val relativePath = URI.createURI(filePath.toString)
       	val path = new Path(relativePath.toString)
		
		val workspace = ResourcesPlugin.getWorkspace()
		val root = workspace.getRoot()
		
		val umlModelIFile = root.getFile(path)
		
        return umlModelIFile.getProject();
	}

	private def Resource getOrCreateResource(URI uri, ResourceSet rs) {
		val existingResource = rs.getResource(uri, false)
		if (existingResource != null) {
			existingResource.contents.clear
			return existingResource
		} else {
			return rs.createResource(uri)
		}
	}

	private def saveResource(Resource resource, BasicExtendedMetaData metadata) {
		try {
			resource.save(#{                                                                                 
			    XMLResource.OPTION_EXTENDED_META_DATA -> metadata,                                           
			    XMLResource.OPTION_ENCODING -> "ISO-8859-1"                                                       
			}) 
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
<?php

namespace NickyDigital\PhotoboothBundle\Controller;

use FOS\RestBundle\Controller\FOSRestController;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Template;
use FOS\RestBundle\Controller\Annotations as Rest;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpFoundation\Response;
use FOS\RestBundle\View\View;
use Symfony\Component\Finder\Finder;

/**
 * User: T. Curran
 * Date: 2/10/13
 */
/**
 * @Route("/")
 */
class ApiController extends FOSRestController {

	/**
	 * @Route("/event", name="api_event")
	 * @Method({"GET"})
	 * @Rest\View
	 */
	public function eventAction()
	{
		return array('event' => "event");
	}

	/**
	 * @Route("/photos", name="api_event")
	 * @Method({"GET"})
	 * @Rest\View
	 */
	public function photosAction()
	{

		$photoListArray = Array();

		$finder = new Finder();
		$finder->files()->in($this->container->get('kernel')->getRootdir() . "/../web/photos");

		$i = 0;
		foreach ($finder as $file) {
			$filename = $file->getFilename();

			if (true || strpos($filename, '.gif', 1) || strpos($filename, '.jpg', 1)) {
				$i++;
				$photo = array();
				$photo['filename'] = $filename;
				$photo['id'] = $i;
	
				array_push($photoListArray, $photo);
			}
		}

			
//		$dir = opendir(__DIR__ . "/_public/photos");
//		$i = 0;
//		while (false !== ($file = readdir($dir))) {
//			if (strpos($file, '.gif', 1) || strpos($file, '.jpg', 1)) {
//				$i++;
//				$photo = new Photo();
//				$photo->filename = $file;
//				$photo->id = $i;
//	
//				array_push($photoListArray, $photo);
//			}
//		}
//	
//		return json_encode($photoListArray);


		return $photoListArray;
	}
	
}

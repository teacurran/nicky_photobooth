<?php

namespace NickyDigital\PhotoboothBundle\Controller;

use FOS\RestBundle\Controller\FOSRestController;
use NickyDigital\PhotoboothBundle\Entity\PhotoEvent;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Route;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Method;
use Sensio\Bundle\FrameworkExtraBundle\Configuration\Template;
use FOS\RestBundle\Controller\Annotations as Rest;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\HttpFoundation\Response;
use FOS\RestBundle\View\View;
use Symfony\Component\Finder\Finder;
use Doctrine\ORM\EntityManager;
use NickyDigital\PhotoboothBundle\Util\ResizedImage;

/**
 * User: T. Curran
 * Date: 2/10/13
 */
/**
 * @Route("/")
 */
class ApiController extends FOSRestController
{

	/**
	 *
	 * @var EntityManager
	 */
	protected $em;

	/**
	 * @Route("/event", name="api_event")
	 * @Method({"GET"})
	 * @Rest\View
	 */
	public function eventAction()
	{

		$event = $this->getCurrentEvent();

		if ($event->getEventCode() == "default") {
			return array(
				"id" => 0,
				"code" => $event->getEventCode(),
				"name" => $event->getEventName(),
			);
			
		}
		return array(
			"id" => $event->getId(),
			"code" => $event->getEventCode(),
			"name" => $event->getEventName(),
			"album_name" => $event->getAlbumName(),
			"short_share" => $event->getShortShareText(),
			"long_share" => $event->getLongShareText()
		);
	}

	/**
	 * @Route("/photos", name="api_photos")
	 * @Method({"GET"})
	 * @Rest\View
	 */
	public function photosAction()
	{

		$event = $this->getCurrentEvent();

		$photoListArray = Array();

		$finder = new Finder();

		$filesDir = $this->getPhotoDir() . "/" . $event->getEventCode();
		if (!$this->rmkdir($filesDir)) {
			die("Failed to create folders:" . $filesDir);
		}

		$finder->files()->in($filesDir);

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

	/**
	 * @Route("/photo/{width}/{code}/{filename}", name="api_photo")
	 * @Method({"GET"})
	 */
	public function photoAction($width, $code, $filename)
	{
		if ($width != "original") {
			if (!is_numeric($width)) {
				throw $this->createNotFoundException('Width must be a number');
			}

		}

		$originalFilename = $this->getPhotoDir() . "/" . $code . "/" . $filename;
		$sizedFileDir = $this->getCacheDir() . "/" . $code . "/" . $width;
		$sizedFilename = $sizedFileDir . "/" . $filename;

		if (!file_exists($originalFilename)) {
			throw $this->createNotFoundException('The product does not exist');
		}

		if ($width == "original") {
			$sizedFilename = $originalFilename;
		} elseif (!file_exists($sizedFilename)) {

			if (!$this->rmkdir($sizedFileDir)) {
				die('Failed to create folders');
			}

			$resizedImage = new ResizedImage();
			$resizedImage->load($originalFilename);
			$resizedImage->resizeToWidth($width);
			$resizedImage->save($sizedFilename);
		}

		$sizedHandle = fopen($sizedFilename, 'r');
		$fileSize = filesize($sizedFilename);

		$response = new Response();
		//$response = $this->getResponse();
		$response->headers->set('Last-Modified', date('r', strtotime(filemtime($originalFilename))));
		$response->headers->set('Content-Type', 'image/jpeg');
		$response->headers->set('Content-Length', $fileSize);

		$response->setContent(fread($sizedHandle, $fileSize));

		fclose($sizedHandle);

		return $response;
	}

	private function getPhotoDir()
	{
		$rootDir = $this->container->get('kernel')->getRootdir(); 
		return substr($rootDir, 0, strlen($rootDir) - 4) . "/photos";
	}

	private function getCacheDir()
	{
		return $this->container->get('kernel')->getRootdir() . "/cache/media";
	}

	/**
	 * Makes directory and returns BOOL(TRUE) if exists OR made.
	 *
	 * @param  $path Path name
	 * @return bool
	 */
	function rmkdir($path, $mode = 0755)
	{
		$path = rtrim(preg_replace(array("/\\\\/", "/\/{2,}/"), "/", $path), "/");
		$e = explode("/", ltrim($path, "/"));
		if (substr($path, 0, 1) == "/") {
			$e[0] = "/" . $e[0];
		}
		$c = count($e);
		$cp = $e[0];
		for ($i = 1; $i < $c; $i++) {
			if (!is_dir($cp) && !@mkdir($cp, $mode)) {
				return false;
			}
			$cp .= "/" . $e[$i];
		}
		if (is_dir($path)) {
			return true;
		}
		return @mkdir($path, $mode);
	}

	function getCurrentEvent() {
		$this->em = $this->get('doctrine.orm.entity_manager');
		
		$query = $this->em->createQuery('SELECT e FROM NickyDigital\PhotoboothBundle\Entity\PhotoEvent e WHERE e.current=true');
		$events = $query->getResult();

		if (count($events) > 0) {
			return $events[0];
		}
		
		$event = new PhotoEvent;
		$event->setEventCode('default');
		$event->setEventName('Default');
		return $event;
	}
}

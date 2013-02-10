<?php

namespace NickyDigital\PhotoboothBundle\Entity;

use Doctrine\ORM\Mapping as ORM;
use Gedmo\Mapping\Annotation as Gedmo;

/**
 * Event
 *
 * @ORM\Table()
 * @ORM\Entity
 */
class PhotoEvent
{
	/**
	 * @var integer
	 *
	 * @ORM\Column(name="id", type="integer")
	 * @ORM\Id
	 * @ORM\GeneratedValue(strategy="AUTO")
	 */
	private $id;

	/**
	 * @ORM\Column(type="string", length=100)
	 */
	protected $eventName;

	/**
	 * @ORM\Column(type="string", length=100)
	 */
	protected $albumName;

	/**
	 * @ORM\Column(type="string", length=200)
	 */
	protected $banner;

	/**
	 * @ORM\Column(type="string", length=100)
	 */
	protected $shortShareText;

	/**
	 * @ORM\Column(type="text")
	 */
	protected $longShareText;

	/**
	 * @ORM\Column(type="boolean")
	 */
	protected $current;

	/**
	 * @ORM\OneToMany(targetEntity="Photo", mappedBy="event")
	 */
	protected $photos;

	/**
	 * @ORM\OneToMany(targetEntity="Email", mappedBy="event")
	 */
	protected $emails;

	/**
	 * @ORM\Column(type="date", nullable=true)
	 */
	protected $eventDate;

	// TODO: figure out why Timestampable isn't populating
	/**
	 * @var datetime $created
	 *
	 * @Gedmo\Timestampable(on="create")
	 * @ORM\Column(type="datetime", nullable=true)
	 */
	protected $created;

	// TODO: figure out why Timestampable isn't populating
	/**
	 * @var datetime $updated
	 *
	 * @Gedmo\Timestampable(on="update")
	 * @ORM\Column(type="datetime", nullable=true)
	 */
	protected $updated;

	public function setAlbumName($albumName)
	{
		$this->albumName = $albumName;
	}

	public function getAlbumName()
	{
		return $this->albumName;
	}

	public function setBanner($banner)
	{
		$this->banner = $banner;
	}

	public function getBanner()
	{
		return $this->banner;
	}

	/**
	 * @param \NickyDigital\PhotoboothBundle\Entity\datetime $created
	 */
	public function setCreated($created)
	{
		$this->created = $created;
	}

	/**
	 * @return \NickyDigital\PhotoboothBundle\Entity\datetime
	 */
	public function getCreated()
	{
		return $this->created;
	}

	public function setCurrent($current)
	{
		$this->current = $current;
	}

	public function getCurrent()
	{
		return $this->current;
	}

	public function setEmails($emails)
	{
		$this->emails = $emails;
	}

	public function getEmails()
	{
		return $this->emails;
	}

	public function setEventDate($eventDate)
	{
		$this->eventDate = $eventDate;
	}

	public function getEventDate()
	{
		return $this->eventDate;
	}

	public function setEventName($eventName)
	{
		$this->eventName = $eventName;
	}

	public function getEventName()
	{
		return $this->eventName;
	}

	/**
	 * @param int $id
	 */
	public function setId($id)
	{
		$this->id = $id;
	}

	/**
	 * @return int
	 */
	public function getId()
	{
		return $this->id;
	}

	public function setLongShareText($longShareText)
	{
		$this->longShareText = $longShareText;
	}

	public function getLongShareText()
	{
		return $this->longShareText;
	}

	public function setPhotos($photos)
	{
		$this->photos = $photos;
	}

	public function getPhotos()
	{
		return $this->photos;
	}

	public function setShortShareText($shortShareText)
	{
		$this->shortShareText = $shortShareText;
	}

	public function getShortShareText()
	{
		return $this->shortShareText;
	}

	/**
	 * @param \NickyDigital\PhotoboothBundle\Entity\datetime $updated
	 */
	public function setUpdated($updated)
	{
		$this->updated = $updated;
	}

	/**
	 * @return \NickyDigital\PhotoboothBundle\Entity\datetime
	 */
	public function getUpdated()
	{
		return $this->updated;
	}


}
